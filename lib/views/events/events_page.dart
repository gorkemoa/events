import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';
import 'package:pixlomi/models/event_models.dart';
import 'package:pixlomi/services/event_service.dart';
import 'package:pixlomi/services/storage_helper.dart';

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
  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
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
        city: '35', // İzmir city code
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

  String _formatFullDate(String dateTimeString) {
    // Expected format: "14.11.2025 15:00"
    try {
      final datePart = dateTimeString.split(' ')[0];
      final parts = datePart.split('.');
      if (parts.length >= 3) {
        final day = parts[0];
        final month = parts[1];
        final year = parts[2];
        final monthNames = [
          '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
          'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
        ];
        final monthIndex = int.tryParse(month) ?? 0;
        if (monthIndex > 0 && monthIndex < monthNames.length) {
          return '$day ${monthNames[monthIndex]} $year';
        }
      }
      return datePart;
    } catch (e) {
      return dateTimeString;
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              HomeHeader(
                locationText: widget.locationText,
                onMenuPressed: widget.onMenuPressed,
                onNotificationPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),

              // Search Bar
              Padding(
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

    const SizedBox(height: 16),
              // Tabs
              Container(
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
                    Tab(text: 'Yaklaşan Etkinlikler'),
                    Tab(text: 'Etkinlik Paylaş'),
                  ],
                ),
              ),

             const SizedBox(height: 16),

              // Events List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Upcoming Events Tab
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Center(
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
                              )
                            : _events.isEmpty
                                ? const Center(
                                    child: Text('Etkinlik bulunamadı'),
                                  )
                                : ListView.separated(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                                    itemCount: _events.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingM),
                                    itemBuilder: (context, index) {
                                      final event = _events[index];
                                      return _EventCard(
                                        image: event.eventImage,
                                        date: _formatDate(event.eventStartDate),
                                        time: _formatTime(event.eventStartDate),
                                        title: event.eventTitle,
                                        location: '${event.eventCity} - ${event.eventDistrict}',
                                        eventStatus: event.eventStatus,
                                        eventEndDate: _formatDate(event.eventEndDate),
                                        isFavorite: false,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EventDetailPage(
                                                eventTitle: event.eventTitle,
                                                clientName: 'Görkem Öztürk',
                                                eventDate: _formatFullDate(event.eventStartDate),
                                                eventTime: _formatTime(event.eventStartDate),
                                                location: event.eventLocation,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                    // Post Events Tab
                    const Center(
                      child: Text('Etkinlik Paylaş'),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
  final bool isFavorite;
  final VoidCallback? onTap;

  const _EventCard({
    required this.image,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.eventStatus,
    required this.eventEndDate,
    required this.isFavorite,
    this.onTap,
  });

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
          // Favorite Icon
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingM),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppTheme.error : AppTheme.textTertiary,
              size: 20,
            ),
          ),
        ],
        ),
      ),
    );
  }
}
