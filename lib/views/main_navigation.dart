import 'package:flutter/material.dart';
import 'package:pixlomi/views/home_page.dart';
import 'package:pixlomi/views/events/events_page.dart';
import 'package:pixlomi/views/profile/profile_page.dart';
import 'package:pixlomi/widgets/custom_bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const EventsPage(),
    const Center(child: Text('Fotoğraflar Sayfası')), // TODO: Implement
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
