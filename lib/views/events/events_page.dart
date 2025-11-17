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

class EventsPage extends StatefulWidget {
  final String locationText;
  final VoidCallback? onMenuPressed;
  
  const EventsPage({
    Key? key,
    required this.locationText,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<models.Event> _events = [];
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
    _tabController = TabController(length: 2, vsync: this);
    _selectedCityName = widget.locationText;
    _loadCities();
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
        
        // widget.locationText ile eşleşen şehri bul
        final matchingCity = _cities.firstWhere(
          (city) => city.cityName.toLowerCase() == widget.locationText.toLowerCase(),
          orElse: () => City(cityNo: 0, cityName: widget.locationText),
        );
        
        // Eşleşme varsa şehir numarasını kullan, yoksa sadece ismi göster
        if (matchingCity.cityNo != 0) {
          setState(() {
            _selectedCityNo = matchingCity.cityNo.toString();
          });
        }
        
        // Etkinlikleri yükle
        _loadEvents();
      } else {
        // API başarısız olsa bile etkinlikleri yükle
        _loadEvents();
      }
    } catch (e) {
      print('Şehirler yüklenirken hata: $e');
      // Hata durumunda da etkinlikleri yükle
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
          '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
          'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
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
                    const Text(
                      'Şehir Seç',
                      style: TextStyle(
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
                  subtitle: const Text(
                    'Mevcut Konum',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  onTap: () {
                    // Mevcut konumun API'de olup olmadığını kontrol et
                    final matchingCity = _cities.firstWhere(
                      (city) => city.cityName.toLowerCase() == widget.locationText.toLowerCase(),
                      orElse: () => City(cityNo: 0, cityName: widget.locationText),
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
                    final isSelected = city.cityNo.toString() == _selectedCityNo;
                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary.withOpacity(0.05) : null,
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
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppTheme.primary, size: 20)
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
        _selectedCityNo = selectedCity.cityNo != 0 ? selectedCity.cityNo.toString() : null;
        
        // Eğer seçilen şehir API'de yoksa ve listede de yoksa, listeye ekle
        if (selectedCity.cityNo == 0 && !_cities.any((c) => c.cityName == selectedCity.cityName)) {
          _cities.insert(0, selectedCity);
        }
      });
      _loadEvents();
    }
  }

  @override
  void dispose() {
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
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Etkinlik ara...',
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
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
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
                  tabs: const [
                    Tab(text: 'Tüm Etkinlikler'),
                    Tab(text: 'Katıldığım Etkinlikler'),
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
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_events.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('Etkinlik bulunamadı'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppTheme.spacingL, 0, AppTheme.spacingL, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = _events[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < _events.length - 1 ? AppTheme.spacingM : 0,
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
                    childCount: _events.length,
                  ),
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
  final VoidCallback? onTap;

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
    this.onTap,
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
        title: const Text('Takvime Ekle'),
        content: Text('$title etkinliğini takviminize eklemek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (shouldAdd != true) return;

    final deviceCalendarPlugin = DeviceCalendarPlugin();
    
    try {
      // İzin kontrolü
      var permissionsGranted = await deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && (permissionsGranted.data == null || !permissionsGranted.data!)) {
        permissionsGranted = await deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || permissionsGranted.data == null || !permissionsGranted.data!) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Takvim izni reddedildi')),
            );
          }
          return;
        }
      }

      // Takvimleri al
      final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null || calendarsResult.data!.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Takvim bulunamadı')),
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
        final isDuplicate = existingEventsResult.data!.any((event) =>
            event.title == title &&
            event.location == location &&
            event.start != null &&
            event.start!.isAtSameMomentAs(tz.TZDateTime.from(startDate, tz.local)));

        if (isDuplicate) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bu etkinlik zaten takviminizde mevcut'),
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

      final createEventResult = await deviceCalendarPlugin.createOrUpdateEvent(calendarEvent);
      
      if (context.mounted) {
        if (createEventResult?.isSuccess == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Etkinlik takvime eklendi'),
              backgroundColor: AppTheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Etkinlik eklenemedi')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                      Icon(Icons.location_on, size: 12, color: AppTheme.textTertiary),
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
                      Icon(Icons.calendar_today, size: 12, color: AppTheme.textTertiary),
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
          // Calendar Icon
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingM),
            child: GestureDetector(
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
          ),
        ],
        ),
      ),
    );
  }
}
