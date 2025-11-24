import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:pixlomi/services/navigation_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';

class DeepLinkService {
  static StreamSubscription? _linkSubscription;
  static String? _pendingEventCode;

  static void initialize() {
    // Handle initial link (when app is closed)
    _handleInitialLink();
    
    // Handle incoming links (when app is open)
    _handleIncomingLinks();
  }

  /// Check if there's a pending deep link to process
  static bool hasPendingLink() => _pendingEventCode != null;

  /// Get and clear pending event code
  static String? getPendingEventCode() {
    final code = _pendingEventCode;
    _pendingEventCode = null;
    return code;
  }

  static Future<void> _handleInitialLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        print('🔗 Initial Deep Link detected: $initialLink');
        _processLink(initialLink, isInitialLink: true);
      }
    } catch (e) {
      print('Error handling initial link: $e');
    }
  }

  static void _handleIncomingLinks() {
    _linkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        _processLink(link, isInitialLink: false);
      }
    }, onError: (err) {
      print('Error listening to link stream: $err');
    });
  }

  static void _processLink(String link, {required bool isInitialLink}) {
    print('🔗 Deep Link received: $link');
    final uri = Uri.parse(link);
    print('🔍 Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    
    // Custom scheme: pixlomi://etkinlik-detay/PX-6UZASX
    if (uri.scheme == 'pixlomi' && uri.host == 'etkinlik-detay') {
      final eventCode = _extractEventCodeFromCustomScheme(uri);
      print('✅ Event code extracted (custom): $eventCode');
      if (eventCode != null) {
        if (isInitialLink) {
          // Store for later processing after splash
          _pendingEventCode = eventCode;
          print('💾 Stored pending event code: $eventCode (will navigate after splash)');
        } else {
          _navigateToEventDetail(eventCode);
        }
      }
    }
    // HTTP/HTTPS: http://pixlomi.com/etkinlik-detay/PX-6UZASX
    else if (uri.host == 'pixlomi.com' && uri.path.startsWith('/etkinlik-detay/')) {
      final eventCode = _extractEventCodeFromWeb(uri);
      print('✅ Event code extracted (web): $eventCode');
      if (eventCode != null) {
        if (isInitialLink) {
          // Store for later processing after splash
          _pendingEventCode = eventCode;
          print('💾 Stored pending event code: $eventCode (will navigate after splash)');
        } else {
          _navigateToEventDetail(eventCode);
        }
      }
    } else {
      print('❌ Link format not recognized');
    }
  }

  static String? _extractEventCodeFromCustomScheme(Uri uri) {
    // Extract code from pixlomi://etkinlik-detay/PX-6UZASX
    final pathSegments = uri.pathSegments;
    print('📍 Path segments: $pathSegments');
    if (pathSegments.isNotEmpty) {
      return pathSegments[0];
    }
    return null;
  }

  static String? _extractEventCodeFromWeb(Uri uri) {
    // Extract code from /etkinlik-detay/PX-6UZASX
    final pathSegments = uri.pathSegments;
    print('📍 Path segments: $pathSegments');
    if (pathSegments.length >= 2 && pathSegments[0] == 'etkinlik-detay') {
      return pathSegments[1];
    }
    return null;
  }

  static void _navigateToEventDetail(String eventCode) async {
    print('🚀 Navigating to EventDetailPage with code: $eventCode');
    
    // Check if user is logged in
    final isLoggedIn = await StorageHelper.isLoggedIn();
    final userToken = await StorageHelper.getUserToken();
    
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      if (isLoggedIn && userToken != null) {
        // User is logged in, navigate to event detail
        print('✅ User logged in, pushing EventDetailPage');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailPage(eventCode: eventCode),
          ),
        );
      } else {
        // User not logged in, save event code and navigate to auth
        print('⚠️ User not logged in, saving event code and navigating to auth');
        await StorageHelper.setPendingDeepLinkEventCode(eventCode);
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } else {
      print('❌ Context is null, delaying navigation');
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 500), () async {
        final retryContext = NavigationService.navigatorKey.currentContext;
        if (retryContext != null) {
          final stillLoggedIn = await StorageHelper.isLoggedIn();
          final stillHasToken = await StorageHelper.getUserToken();
          
          if (stillLoggedIn && stillHasToken != null) {
            print('✅ User logged in after delay, pushing EventDetailPage');
            Navigator.of(retryContext).push(
              MaterialPageRoute(
                builder: (context) => EventDetailPage(eventCode: eventCode),
              ),
            );
          } else {
            print('⚠️ User not logged in after delay, saving event code and navigating to auth');
            await StorageHelper.setPendingDeepLinkEventCode(eventCode);
            Navigator.of(retryContext).pushNamedAndRemoveUntil('/auth', (route) => false);
          }
        } else {
          print('❌ Context still null after delay');
        }
      });
    }
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }
}
