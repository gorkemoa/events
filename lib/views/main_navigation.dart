import 'package:flutter/material.dart';
import 'package:pixlomi/views/home_page.dart';
import 'package:pixlomi/views/events/events_page.dart';
import 'package:pixlomi/views/gallery/gallery_page.dart';
import 'package:pixlomi/views/profile/profile_page.dart';
import 'package:pixlomi/widgets/custom_bottom_nav.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _locationText = 'Konum yükleniyor...';

  @override
  void initState() {
    super.initState();
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

  List<Widget> get _pages => [
    HomePage(locationText: _locationText),
    EventsPage(locationText: _locationText),
    const GalleryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
