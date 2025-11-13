import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:pixlomi/theme/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  Color _iconColor(int index) {
    return selectedIndex == index ? AppTheme.primary : Colors.white70;
  }

  double _iconSize(int index) {
    return selectedIndex == index ? 30 : 22; // 🔥 sadece seçili büyür
  }

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.custom,
      height: 64,
      curveSize: 100,
      backgroundColor: AppTheme.primary,
      activeColor: Colors.white,
      color: Colors.white70,
      initialActiveIndex: selectedIndex,
      onTap: onTap,
      items: [
        TabItem(
          title: 'Anasayfa',
          icon: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.home,
              color: _iconColor(0),
              size: _iconSize(0),
            ),
          ),
        ),
        TabItem(
          title: 'Etkinlikler',
          icon: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.calendar_today,
              color: _iconColor(1),
              size: _iconSize(1),
            ),
          ),
        ),
        TabItem(
          title: 'Fotoğraflar',
          icon: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.image,
              color: _iconColor(2),
              size: _iconSize(2),
            ),
          ),
        ),
        TabItem(
          title: 'Profil',
          icon: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.person,
              color: _iconColor(3),
              size: _iconSize(3),
            ),
          ),
        ),
      ],
    );
  }
}
