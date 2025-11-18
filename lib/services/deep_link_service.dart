import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:pixlomi/services/navigation_service.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';

class DeepLinkService {
  static StreamSubscription? _linkSubscription;

  static void initialize() {
    // Handle initial link (when app is closed)
    _handleInitialLink();
    
    // Handle incoming links (when app is open)
    _handleIncomingLinks();
  }

  static Future<void> _handleInitialLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _processLink(initialLink);
      }
    } catch (e) {
      print('Error handling initial link: $e');
    }
  }

  static void _handleIncomingLinks() {
    _linkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        _processLink(link);
      }
    }, onError: (err) {
      print('Error listening to link stream: $err');
    });
  }

  static void _processLink(String link) {
    print('🔗 Deep Link received: $link');
    final uri = Uri.parse(link);
    print('🔍 Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    
    // Custom scheme: pixlomi://etkinlik-detay/PX-6UZASX
    if (uri.scheme == 'pixlomi' && uri.host == 'etkinlik-detay') {
      final eventCode = _extractEventCodeFromCustomScheme(uri);
      print('✅ Event code extracted (custom): $eventCode');
      if (eventCode != null) {
        _navigateToEventDetail(eventCode);
      }
    }
    // HTTP/HTTPS: http://pixlomi.com/etkinlik-detay/PX-6UZASX
    else if (uri.host == 'pixlomi.com' && uri.path.startsWith('/etkinlik-detay/')) {
      final eventCode = _extractEventCodeFromWeb(uri);
      print('✅ Event code extracted (web): $eventCode');
      if (eventCode != null) {
        _navigateToEventDetail(eventCode);
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

  static void _navigateToEventDetail(String eventCode) {
    print('🚀 Navigating to EventDetailPage with code: $eventCode');
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      print('✅ Context available, pushing route');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventDetailPage(eventCode: eventCode),
        ),
      );
    } else {
      print('❌ Context is null, delaying navigation');
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        final retryContext = NavigationService.navigatorKey.currentContext;
        if (retryContext != null) {
          print('✅ Context available after delay, pushing route');
          Navigator.of(retryContext).push(
            MaterialPageRoute(
              builder: (context) => EventDetailPage(eventCode: eventCode),
            ),
          );
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
