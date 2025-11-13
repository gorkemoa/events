import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String locationText;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onLocationPressed;
  final String? subtitle;
  final IconData? notificationIcon;

  const HomeHeader({
    Key? key,
    required this.locationText,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onLocationPressed,
    this.subtitle,
    this.notificationIcon,
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
          GestureDetector(
            onTap: onLocationPressed,
            child: Column(
              children: [
                Text(
                  subtitle ?? 'Mevcut Konum',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      locationText,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (subtitle == null)
                      Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[800]),
                  ],
                ),
              ],
            ),
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
              child: Icon(notificationIcon ?? Icons.notifications_outlined, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
