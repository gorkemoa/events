import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';

class HomePage extends StatefulWidget {
  final String locationText;
  
  const HomePage({Key? key, required this.locationText}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    // Ortadan başlayarak sonsuz döngü efekti
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 1000, // Büyük bir sayıdan başla
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
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

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Location and Notification
              HomeHeader(
                locationText: widget.locationText,
                onMenuPressed: () {},
                onNotificationPressed: () {},
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

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
                        backgroundColor: const Color.fromARGB(255, 241, 245, 201),
                      ),
                      _ServiceCard(
                        title: 'Doğum Günü\nFotoğrafçılığı',
                        icon: Icons.celebration,
                        backgroundColor: const Color(0xFFE3F2FD),
                      ),
                      _ServiceCard(
                        title: 'Düğün\nFotoğrafçılığı',
                        icon: Icons.favorite,
                        backgroundColor: const Color(0xFFFCE4EC),
                      ),
                      _ServiceCard(
                        title: 'Nişan\nFotoğrafçılığı',
                        icon: Icons.diamond,
                        backgroundColor: const Color(0xFFF3E5F5),
                      ),
                    ];
                    return services[serviceIndex];
                  },
                ),
              ),

              const SizedBox(height: 25),

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
                              'Fotoğraflarınızı paylaşılan\nonay kodu/QR ile görüntüleyin',
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
                                      decoration: InputDecoration(
                                        hintText: 'Olay kodunu girin veya tarayın',
                                        hintStyle: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(4),
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
                                      size: 20,
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

              // Upcoming Events
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Yaklaşan Etkinlikler',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _EventCard(
                      day: '10',
                      month: 'ARA',
                      title: 'Yıldönümü\nEtkinliği',
                      color: const Color(0xFFFFE5EC),
                    ),
                    const SizedBox(width: 12),
                    _EventCard(
                      day: '10',
                      month: 'ARA',
                      title: 'Doğum Günü\nKutlaması',
                      color: const Color(0xFFE3F2FD),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
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

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppTheme.primary,
          ),
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
      ),
    );
  }
}

// Event Card Widget
class _EventCard extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final Color color;

  const _EventCard({
    required this.day,
    required this.month,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
                    Text(
                      month,
                      style: AppTheme.captionSmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bookmark_border,
                    size: 20,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTheme.labelSmall,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
