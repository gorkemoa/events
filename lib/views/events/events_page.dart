import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh events logic can be added here
          await Future.delayed(const Duration(seconds: 1));
        },
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
                    ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                      children: [
                        _EventCard(
                          image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
                          date: '9 Kasım',
                          time: '12:00 ÖÖ',
                          title: 'FO Kahve Festivali',
                          location: 'İzmir - Konak',
                          organizer: 'Fo - Özmer',
                          isFavorite: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventDetailPage(
                                  eventTitle: 'FO Kahve Festivali',
                                  clientName: 'Görkem Öztürk',
                                  eventDate: '9 Kasım 2025',
                                  eventTime: '12:00',
                                  location: 'İzmir - Konak',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        _EventCard(
                          image: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400&h=400&fit=crop',
                          date: '11 Kasım',
                          time: '09:00 ÖÖ',
                          title: '8. Teknoloji Zirvesi',
                          location: 'İstanbul - Taksim',
                          organizer: 'Office701 Holding',
                          isFavorite: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventDetailPage(
                                  eventTitle: '8. Teknoloji Zirvesi',
                                  clientName: 'Görkem Öztürk',
                                  eventDate: '11 Kasım 2025',
                                  eventTime: '09:00',
                                  location: 'İstanbul - Taksim',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
  final String organizer;
  final bool isFavorite;
  final VoidCallback? onTap;

  const _EventCard({
    required this.image,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.organizer,
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
                      Icon(Icons.person_outline, size: 12, color: AppTheme.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          organizer,
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
