import 'package:flutter/material.dart';

/// Global navigation service for app-wide navigation
/// 
/// This service allows navigation without BuildContext using a GlobalKey
/// Useful for handling navigation from services or background tasks
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to login page and clear navigation stack
  /// Used when user is unauthorized (403) or token expires
  static Future<void> navigateToLogin() async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Clear all routes and navigate to login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  /// Navigate to a named route
  static Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  /// Navigate to a named route and remove all previous routes
  static Future<dynamic>? navigateToAndRemoveAll(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to previous route
  static void goBack() {
    navigatorKey.currentState?.pop();
  }
}
