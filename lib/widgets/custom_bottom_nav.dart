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

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.custom,
      items: const [
        TabItem(
          icon: Icons.home,
          title: 'Anasayfa',
        ),
        TabItem(
          icon: Icons.calendar_today,
          title: 'Etkinlikler',
        ),
        TabItem(
          icon: Icons.image,
          title: 'Fotoğraflar',
        ),
        TabItem(
          icon: Icons.person,
          title: 'Profil',
        ),
      ],
      initialActiveIndex: selectedIndex,
      onTap: onTap,
      backgroundColor: AppTheme.primary,
      activeColor: Colors.white,
      color: Colors.white70,
      height: 49,
      curveSize: 100,
    );
  }
}
