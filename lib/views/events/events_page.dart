import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _locationText = 'Konum yükleniyor...';


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Konum izni kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationText = 'İzin verilmedi';
          });
          return;
        }
      }

      // Mevcut konumu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Koordinatlardan adres al
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locationName = '${place.locality}';
        setState(() {
          _locationText = locationName;
        });
      }
    } catch (e) {
      setState(() {
        _locationText = 'Türkiye';
      });
    }
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            HomeHeader(
              locationText: _locationText,
              onMenuPressed: () {},
              onNotificationPressed: () {},
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _EventCard(
                        image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
                        date: '9 Haziran',
                        time: '12:00 ÖÖ',
                        title: 'Doğum Günü Kutlaması',
                        location: 'Farmhouse, NY',
                        organizer: 'Bay Adam',
                        isFavorite: true,
                      ),
                      const SizedBox(height: 16),
                      _EventCard(
                        image: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400&h=400&fit=crop',
                        date: '11 Haziran',
                        time: '09:00 ÖÖ',
                        title: 'Düğün Öncesi Kutlama',
                        location: 'Farmhouse, NY',
                        organizer: 'Bay Adam',
                        isFavorite: false,
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

  const _EventCard({
    required this.image,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.organizer,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              image,
              width: 100,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          // Event Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$date - ',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        organizer,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
