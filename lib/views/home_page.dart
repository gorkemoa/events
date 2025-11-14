import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/models/user_models.dart';
import 'package:pixlomi/views/qr/qr_scanner_page.dart';
import 'package:pixlomi/services/event_service.dart';
import 'package:pixlomi/models/event_models.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';

class HomePage extends StatefulWidget {
  final String locationText;
  final VoidCallback? onMenuPressed;

  const HomePage({Key? key, required this.locationText, this.onMenuPressed})
    : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _userService = UserService();
  late PageController _pageController;
  Timer? _autoScrollTimer;
  User? _currentUser;
  final TextEditingController _eventCodeController = TextEditingController();
  final FocusNode _eventCodeFocusNode = FocusNode();
  bool _isSearching = false;
  List<Event> _attendedEvents = [];
  bool _isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    // Ortadan başlayarak sonsuz döngü efekti
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 1000, // Büyük bir sayıdan başla
    );
    _startAutoScroll();
    _loadUserData();
    _loadAttendedEvents();

    // TextField focus listener
    _eventCodeFocusNode.addListener(() {
      setState(() {
        _isSearching =
            _eventCodeFocusNode.hasFocus ||
            _eventCodeController.text.isNotEmpty;
      });
    });

    // Text değişikliği listener
    _eventCodeController.addListener(() {
      setState(() {
        _isSearching =
            _eventCodeFocusNode.hasFocus ||
            _eventCodeController.text.isNotEmpty;
      });
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await StorageHelper.getUserId();
      final userToken = await StorageHelper.getUserToken();

      if (userId != null && userToken != null) {
        final response = await _userService.getUserById(
          userId: userId,
          userToken: userToken,
        );

        if (response.isSuccess && response.data != null) {
          setState(() {
            _currentUser = response.data!.user;
          });
        }
      }
    } catch (e) {
      // Sessizce hata yakalama, kullanıcı deneyimini etkilememek için
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadAttendedEvents() async {
    try {
      setState(() {
        _isLoadingEvents = true;
      });

      final userToken = await StorageHelper.getUserToken();

      if (userToken == null || userToken.isEmpty) {
        setState(() {
          _isLoadingEvents = false;
        });
        return;
      }

      final response = await EventService.getAllEvents(userToken);

      if (response != null && response.success) {
        // Sadece eşleşen fotoğrafı olan etkinlikleri filtrele (imageCount > 0)
        final attendedEvents = response.data.events
            .where((event) => event.imageCount > 0)
            .toList();

        setState(() {
          _attendedEvents = attendedEvents;
          _isLoadingEvents = false;
        });
      } else {
        setState(() {
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading attended events: $e');
      setState(() {
        _isLoadingEvents = false;
      });
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = _pageController.page! + 1;
        _pageController.animateToPage(
          nextPage.toInt(),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _searchEventCode(String eventCode) {
    // Event kodu ile arama yap
    debugPrint('🔍 Searching for event code: $eventCode');

    // TextField'ı temizle ve focus'u kaldır
    _eventCodeController.clear();
    _eventCodeFocusNode.unfocus();

    // TODO: API çağrısı ile event kodunu ara
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$eventCode kodu aranıyor...'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _scanQRCode() async {
    // QR kod okuyucu aç
    debugPrint('📷 Opening QR code scanner...');

    try {
      // QR Scanner sayfasını aç
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerPage()),
      );

      // QR koddan dönen sonucu işle
      if (result != null && result is String) {
        debugPrint('✅ QR Code result: $result');

        // Event kodunu ara
        _searchEventCode(result);
      }
    } catch (e) {
      debugPrint('❌ QR Scanner error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR okuma hatası: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _eventCodeController.dispose();
    _eventCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: AppTheme.primary,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Location and Notification
                HomeHeader(
                  locationText: widget.locationText,
                  subtitle: _currentUser != null
                      ? 'Hoş geldin, ${_currentUser!.userFirstname}'
                      : null,
                  onMenuPressed: widget.onMenuPressed,
                  onNotificationPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ne arıyorsunuz?',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // View pictures with QR Code section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Left side image
                        Container(
                          width: 55,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/icon/71252051.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right side content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Etkinlik Kodunu Girin veya QR Tarayın',
                                style: AppTheme.labelSmall,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _eventCodeController,
                                        focusNode: _eventCodeFocusNode,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        maxLength: 6,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              _eventCodeFocusNode.hasFocus ||
                                                  _eventCodeController
                                                      .text
                                                      .isNotEmpty
                                              ? null
                                              : 'PX-XXXXXX',
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                          ),
                                          prefixText:
                                              _eventCodeFocusNode.hasFocus ||
                                                  _eventCodeController
                                                      .text
                                                      .isNotEmpty
                                              ? 'PX-'
                                              : null,
                                          prefixStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                          ),
                                          counterText: '',
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                        ),
                                        onSubmitted: (value) {
                                          if (value.length == 6) {
                                            _searchEventCode('PX-$value');
                                          }
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (_isSearching &&
                                            _eventCodeController.text.length ==
                                                6) {
                                          _searchEventCode(
                                            'PX-${_eventCodeController.text}',
                                          );
                                        } else if (!_isSearching) {
                                          _scanQRCode();
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color:
                                              (_isSearching &&
                                                  _eventCodeController
                                                          .text
                                                          .length ==
                                                      6)
                                              ? AppTheme.primary
                                              : !_isSearching
                                              ? AppTheme.primary
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isSearching &&
                                                  _eventCodeController
                                                      .text
                                                      .isNotEmpty
                                              ? Icons.search
                                              : Icons.qr_code_scanner,
                                          color:
                                              (_isSearching &&
                                                  _eventCodeController
                                                          .text
                                                          .length ==
                                                      6)
                                              ? Colors.white
                                              : !_isSearching
                                              ? Colors.white
                                              : Colors.grey[500],
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Explore our services
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hizmetlerimizi Keşfedin',
                        style: AppTheme.labelLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Services Carousel
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      // Sonsuz döngü için modulo kullan
                      final serviceIndex = index % 4;
                      final services = [
                        _ServiceCard(
                          title: 'Yıldönümü\nFotoğrafçılığı',
                          icon: Icons.cake,
                          backgroundColor: const Color.fromARGB(
                            255,
                            241,
                            245,
                            201,
                          ),
                          imagePath: 'assets/slider/foto3.jpg',
                        ),
                        _ServiceCard(
                          title: 'Doğum Günü\nFotoğrafçılığı',
                          icon: Icons.celebration,
                          backgroundColor: const Color(0xFFE3F2FD),
                          imagePath: 'assets/slider/foto4.png',
                        ),
                        _ServiceCard(
                          title: 'Düğün\nFotoğrafçılığı',
                          icon: Icons.favorite,
                          backgroundColor: const Color(0xFFFCE4EC),
                          imagePath: 'assets/slider/foto5.png',
                        ),
                        _ServiceCard(
                          title: 'Nişan\nFotoğrafçılığı',
                          icon: Icons.diamond,
                          backgroundColor: const Color(0xFFF3E5F5),
                          imagePath: 'assets/slider/foto13.jpeg',
                        ),
                      ];
                      return services[serviceIndex];
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Upcoming Events
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Katıldığım Etkinlikler',
                        style: AppTheme.labelLarge,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Tümünü Gör >',
                          style: AppTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Events List
                _isLoadingEvents
                    ? const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _attendedEvents.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Henüz katıldığınız etkinlik yok',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 130,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: _attendedEvents.length,
                          itemBuilder: (context, index) {
                            final event = _attendedEvents[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < _attendedEvents.length - 1
                                    ? 12
                                    : 0,
                              ),
                              child: _EventCard(
                                event: event,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailPage(
                                        eventID: event.eventID,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Service Card Widget - Modern design with icon
class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final String? imagePath;

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: imagePath != null ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(16),
        image: imagePath != null
            ? DecorationImage(image: AssetImage(imagePath!), fit: BoxFit.cover)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: imagePath == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: AppTheme.primary),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTheme.labelSmall,
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }
}

// Event Card Widget
class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const _EventCard({required this.event, this.onTap});

  String _formatDate(String dateTimeString) {
    try {
      // Format: "14.11.2025 15:00" -> "14"
      final parts = dateTimeString.split(' ');
      final dateParts = parts[0].split('.');
      return dateParts[0]; // day
    } catch (e) {
      return '00';
    }
  }

  String _formatMonth(String dateTimeString) {
    try {
      // Format: "14.11.2025 15:00" -> "KAS"
      final parts = dateTimeString.split(' ');
      final dateParts = parts[0].split('.');
      final month = int.parse(dateParts[1]);

      const months = [
        'OCA',
        'ŞUB',
        'MAR',
        'NİS',
        'MAY',
        'HAZ',
        'TEM',
        'AĞU',
        'EYL',
        'EKİ',
        'KAS',
        'ARA',
      ];

      return months[month - 1];
    } catch (e) {
      return 'AY';
    }
  }

  Color _getEventColor(int index) {
    final colors = [
      const Color(0xFFFFE5EC),
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFF3E5F5),
      const Color(0xFFE8F5F9),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final day = _formatDate(event.eventStartDate);
    final month = _formatMonth(event.eventStartDate);
    final color = _getEventColor(event.eventID);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(month, style: AppTheme.captionSmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 14,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.imageCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.eventTitle,
              style: AppTheme.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
