import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final String locationText;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final String? subtitle;

  const HomeHeader({
    Key? key,
    required this.locationText,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu Icon
          GestureDetector(
            onTap: onMenuPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu, size: 24),
            ),
          ),
          // Location
          Column(
            children: [
              Text(
                subtitle ?? 'Mevcut Konum',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  Text(
                    locationText,
                    style: AppTheme.labelMedium,
                  ),
                  if (subtitle == null)
                    Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[800]),
                ],
              ),
            ],
          ),
          // Notification Icon
          GestureDetector(
            onTap: onNotificationPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_outlined, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
