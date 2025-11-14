import 'package:flutter/material.dart';
import 'package:pixlomi/views/home_page.dart';
import 'package:pixlomi/views/events/events_page.dart';
import 'package:pixlomi/views/gallery/gallery_page.dart';
import 'package:pixlomi/views/profile/profile_page.dart';
import 'package:pixlomi/widgets/custom_bottom_nav.dart';
import 'package:pixlomi/widgets/app_drawer.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
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
  String? _userFullname;
  String? _userEmail;
  String? _profilePhoto;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserData();
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
        String locationName = '${place.administrativeArea}';
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
            _userFullname = response.data!.user.userFullname;
            _userEmail = response.data!.user.userEmail;
            _profilePhoto = response.data!.user.profilePhoto;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  List<Widget> get _pages => [
    HomePage(locationText: _locationText, onMenuPressed: _openDrawer),
    EventsPage(locationText: _locationText, onMenuPressed: _openDrawer),
    GalleryPage(onMenuPressed: _openDrawer),
    ProfilePage(onMenuPressed: _openDrawer),
  ];

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        userFullname: _userFullname,
        userEmail: _userEmail,
        profilePhoto: _profilePhoto,
        onPageSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
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
