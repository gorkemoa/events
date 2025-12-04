import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';
import 'package:pixlomi/models/event_models.dart' as models;
import 'package:pixlomi/models/city_models.dart';
import 'package:pixlomi/services/event_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/general_service.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:pixlomi/localizations/app_localizations.dart';

class EventsPage extends StatefulWidget {
  final String locationText;
  final VoidCallback? onMenuPressed;
  final int initialTabIndex;

  const EventsPage({
    Key? key,
    required this.locationText,
    this.onMenuPressed,
    this.initialTabIndex = 0,
  }) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<models.Event> _events = [];
  List<models.Event> _filteredEvents = [];
  List<City> _cities = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  late String _selectedCityName;
  String? _selectedCityNo;
  final GeneralService _generalService = GeneralService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_onTabChanged);
    _selectedCityName = widget.locationText;
    _loadCities();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _filterEvents();
  }

  void _filterEvents() {
    setState(() {
      if (_tabController.index == 0) {
        // Tüm Etkinlikler
        _filteredEvents = _events;
      } else {
        // Katıldığım Etkinlikler
        _filteredEvents = _events.where((event) => event.isJoined).toList();
      }
    });
  }

  @override
  void didUpdateWidget(EventsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locationText != widget.locationText) {
      setState(() {
        _selectedCityName = widget.locationText;
      });
      _loadCities();
    }
  }

  Future<void> _loadCities() async {
    try {
      final response = await _generalService.getAllCities();
      if (response.isSuccess && response.data != null) {
        _cities = response.data!.cities;

        // Varsayılan olarak "Tümü" seçeneğini seç (cityNo: 0)
        final allCityOption = _cities.firstWhere(
          (city) => city.cityNo == 0,
          orElse: () => City(cityNo: 0, cityName: 'Tümü'),
        );

        setState(() {
          _selectedCityNo = '0';
          _selectedCityName = allCityOption.cityName;
        });

        // Etkinlikleri yükle
        _loadEvents();
      } else {
        // API başarısız olsa bile etkinlikleri yükle
        setState(() {
          _selectedCityNo = '0';
          _selectedCityName = 'Tümü';
        });
        _loadEvents();
      }
    } catch (e) {
      print('Şehirler yüklenirken hata: $e');
      // Hata durumunda da etkinlikleri yükle
      setState(() {
        _selectedCityNo = '0';
        _selectedCityName = 'Tümü';
      });
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userToken = await StorageHelper.getUserToken();

      if (userToken == null || userToken.isEmpty) {
        setState(() {
          _errorMessage = 'Kullanıcı oturumu bulunamadı';
          _isLoading = false;
        });
        return;
      }

      final response = await EventService.getAllEvents(
        userToken,
        city: _selectedCityNo,
        searchText: _searchText.isEmpty ? null : _searchText,
      );

      if (response != null && response.success) {
        setState(() {
          _events = response.data.events;
          _isLoading = false;
        });
        _filterEvents();
      } else {
        setState(() {
          _errorMessage = 'Etkinlikler yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateTimeString) {
    // Expected format: "14.11.2025 15:00"
    try {
      final datePart = dateTimeString.split(' ')[0];
      final parts = datePart.split('.');
      if (parts.length >= 2) {
        final day = parts[0];
        final month = parts[1];
        final monthNames = [
          '',
          'Ocak',
          'Şubat',
          'Mart',
          'Nisan',
          'Mayıs',
          'Haziran',
          'Temmuz',
          'Ağustos',
          'Eylül',
          'Ekim',
          'Kasım',
          'Aralık',
        ];
        final monthIndex = int.tryParse(month) ?? 0;
        if (monthIndex > 0 && monthIndex < monthNames.length) {
          return '$day ${monthNames[monthIndex]}';
        }
      }
      return datePart;
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatTime(String dateTimeString) {
    // Expected format: "14.11.2025 15:00"
    try {
      final timePart = dateTimeString.split(' ')[1];
      return timePart;
    } catch (e) {
      return '';
    }
  }

  Future<void> _showCityPicker() async {
    final selectedCity = await showDialog<City>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.cardBorderRadius),
                    topRight: Radius.circular(AppTheme.cardBorderRadius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('events.select_city'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Mevcut Konum Butonu
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.dividerColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingS,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(
                    widget.locationText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  subtitle: Text(
                    context.tr('events.current_location'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  onTap: () {
                    // Mevcut konumun API'de olup olmadığını kontrol et
                    final matchingCity = _cities.firstWhere(
                      (city) =>
                          city.cityName.toLowerCase() ==
                          widget.locationText.toLowerCase(),
                      orElse: () =>
                          City(cityNo: 0, cityName: widget.locationText),
                    );
                    Navigator.pop(context, matchingCity);
                  },
                ),
              ),
              // Şehir Listesi
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected =
                        city.cityNo.toString() == _selectedCityNo;
                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withOpacity(0.05)
                            : null,
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.dividerColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingL,
                          vertical: AppTheme.spacingXS,
                        ),
                        title: Text(
                          city.cityName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppTheme.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context, city);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedCity != null) {
      setState(() {
        _selectedCityName = selectedCity.cityName;
        _selectedCityNo = selectedCity.cityNo.toString();
      });
      _loadEvents();
    }
  }

  Future<void> _sendScanRequest(int eventID) async {
    try {
      final userToken = await StorageHelper.getUserToken();

      if (userToken == null || userToken.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('notifications.session_error')),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Loading göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(context.tr('events.scan_sending')),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final response = await EventService.sendScanRequest(userToken, eventID);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (response != null && response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: AppTheme.primary,
            ),
          );
          // Listeyi yenile
          _loadEvents();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response?.message ?? context.tr('events.scan_send_error'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverSafeArea(
              sliver: SliverToBoxAdapter(
                child: HomeHeader(
                  locationText: _selectedCityName,
                  onMenuPressed: widget.onMenuPressed,
                  onNotificationPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                  onLocationPressed: _showCityPicker,
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.tr('events.search_placeholder'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchText = '';
                              });
                              _loadEvents();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  onSubmitted: (value) {
                    _loadEvents();
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Tabs
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(text: context.tr('events.all_events')),
                    Tab(text: context.tr('events.my_events')),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Events List Content
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEvents,
                        child: Text(context.tr('events.button_retry')),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredEvents.isEmpty)
              SliverFillRemaining(
                child: Center(child: Text(context.tr('events.no_events'))),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingL,
                  0,
                  AppTheme.spacingL,
                  20,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final event = _filteredEvents[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _filteredEvents.length - 1
                            ? AppTheme.spacingM
                            : 0,
                      ),
                      child: _EventCard(
                        image: event.eventImage,
                        date: _formatDate(event.eventStartDate),
                        time: _formatTime(event.eventStartDate),
                        title: event.eventTitle,
                        location: '${event.eventCity} - ${event.eventDistrict}',
                        eventStatus: event.eventStatus,
                        eventEndDate: _formatDate(event.eventEndDate),
                        eventStartDate: event.eventStartDate,
                        eventEndDateFull: event.eventEndDate,
                        hasScanRequest: event.hasScanRequest,
                        scanedStatus: event.scanedStatus,
                        imageCount: event.imageCount,
                        eventID: event.eventID,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailPage(eventID: event.eventID),
                            ),
                          );
                        },
                        onScanRequest: () => _sendScanRequest(event.eventID),
                      ),
                    );
                  }, childCount: _filteredEvents.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String image;
  final String date;
  final String time;
  final String title;
  final String location;
  final String eventStatus;
  final String eventEndDate;
  final String eventStartDate;
  final String eventEndDateFull;
  final bool hasScanRequest;
  final int scanedStatus; // 0: tarama yok, 1: tarama tamamlandı, 2: taranıyor
  final int imageCount;
  final int eventID;
  final VoidCallback? onTap;
  final Future<void> Function()? onScanRequest;

  const _EventCard({
    required this.image,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.eventStatus,
    required this.eventEndDate,
    required this.eventStartDate,
    required this.eventEndDateFull,
    required this.hasScanRequest,
    required this.scanedStatus,
    required this.imageCount,
    required this.eventID,
    this.onTap,
    this.onScanRequest,
  });

  DateTime _parseEventDateTime(String dateTimeString) {
    try {
      // Format: "14.11.2025 15:00"
      final parts = dateTimeString.split(' ');
      final dateParts = parts[0].split('.');
      final timeParts = parts[1].split(':');

      return DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[0]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> _addToCalendar(BuildContext context) async {
    // Önce kullanıcıya onay sor
    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('events.calendar_title')),
        content: Text(
          context.tr('events.calendar_confirm', args: {'title': title}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('events.calendar_add')),
          ),
        ],
      ),
    );

    if (shouldAdd != true) return;

    final deviceCalendarPlugin = DeviceCalendarPlugin();

    try {
      // İzin kontrolü
      var permissionsGranted = await deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess &&
          (permissionsGranted.data == null || !permissionsGranted.data!)) {
        permissionsGranted = await deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess ||
            permissionsGranted.data == null ||
            !permissionsGranted.data!) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('events.calendar_permission_denied')),
              ),
            );
          }
          return;
        }
      }

      // Takvimleri al
      final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess ||
          calendarsResult.data == null ||
          calendarsResult.data!.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('events.calendar_not_found'))),
          );
        }
        return;
      }

      // İlk takvimi seç (varsayılan takvim)
      final calendarId = calendarsResult.data!.first.id;

      final startDate = _parseEventDateTime(eventStartDate);
      final endDate = _parseEventDateTime(eventEndDateFull);

      // Aynı etkinliğin daha önce eklenip eklenmediğini kontrol et
      final existingEventsResult = await deviceCalendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(
          startDate: startDate.subtract(const Duration(hours: 1)),
          endDate: endDate.add(const Duration(hours: 1)),
        ),
      );

      if (existingEventsResult.isSuccess && existingEventsResult.data != null) {
        final isDuplicate = existingEventsResult.data!.any(
          (event) =>
              event.title == title &&
              event.location == location &&
              event.start != null &&
              event.start!.isAtSameMomentAs(
                tz.TZDateTime.from(startDate, tz.local),
              ),
        );

        if (isDuplicate) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('events.calendar_duplicate')),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      final calendarEvent = Event(
        calendarId,
        title: title,
        description: 'Etkinlik Durumu: $eventStatus',
        location: location,
        start: tz.TZDateTime.from(startDate, tz.local),
        end: tz.TZDateTime.from(endDate, tz.local),
      );

      final createEventResult = await deviceCalendarPlugin.createOrUpdateEvent(
        calendarEvent,
      );

      if (context.mounted) {
        if (createEventResult?.isSuccess == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('events.calendar_success')),
              backgroundColor: AppTheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('events.calendar_failed'))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('common.error', args: {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showScanDialog(BuildContext context) async {
    final shouldScan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.document_scanner,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('events.scan_request_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('events.scan_request_message'),
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('events.scan_request_info'),
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.tr('common.cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.tr('events.scan_request_button')),
          ),
        ],
      ),
    );

    if (shouldScan == true && onScanRequest != null) {
      await onScanRequest!();
    }
  }

  void _showNoPhotosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('events.scan_no_photos_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('events.scan_no_photos_message'),
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.tr('common.ok')),
          ),
        ],
      ),
    );
  }

  void _showScanningInProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.hourglass_top,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('events.scan_in_progress_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('events.scan_in_progress_message'),
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('events.scan_in_progress_info'),
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.tr('common.ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // scanedStatus: 0 = tarama yok, 1 = tarama tamamlandı, 2 = taranıyor
        if (scanedStatus == 0) {
          // Tarama isteği yok, tarama talebi gönder dialog'u
          _showScanDialog(context);
        } else if (scanedStatus == 2) {
          // Taranıyor, bekle mesajı
          _showScanningInProgressDialog(context);
        } else if (scanedStatus == 1 && imageCount == 0) {
          // Tarama tamamlandı ama fotoğraf yok
          _showNoPhotosDialog(context);
        } else {
          // Tarama tamamlandı ve fotoğraf var, detaya git
          onTap?.call();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.cardBorderRadius),
                bottomLeft: Radius.circular(AppTheme.cardBorderRadius),
              ),
              child: Image.network(
                image,
                width: 80,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$date - ',
                          style: AppTheme.captionSmall.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          time,
                          style: AppTheme.captionSmall.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            eventStatus,
                            style: AppTheme.captionSmall.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      title,
                      style: AppTheme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: AppTheme.captionSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Etkinlik Son Tarihi: $eventEndDate',
                            style: AppTheme.captionSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Calendar Icon
                  GestureDetector(
                    onTap: () => _addToCalendar(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  // Scan Button - only show when scanedStatus is 0 (no scan request)
                  if (scanedStatus == 0) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showScanDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.document_scanner,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                  // Scanning in progress indicator - show when scanedStatus is 2
                  if (scanedStatus == 2) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showScanningInProgressDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.hourglass_top,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
