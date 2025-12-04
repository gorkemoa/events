import 'dart:convert';
import 'dart:developer' as developer;
import '../models/event_models.dart';
import 'api_helper.dart';
import 'constants.dart';

/// Service for handling event-related API calls
class EventService {
  /// Fetch all events for a user
  static Future<EventsResponse?> getAllEvents(
    String userToken, {
    String? city,
    String? searchText,
  }) async {
    try {
      developer.log(
        'Fetching events for user token: $userToken, city: $city, searchText: $searchText',
        name: 'EventService',
      );

      final url = ApiConstants.getAllEvents(
        userToken,
        city: city,
        searchText: searchText,
      );
      developer.log('URL: $url', name: 'EventService');

      final response = await ApiHelper.get(url);

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'EventService',
      );
      developer.log('Response body: ${response.body}', name: 'EventService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final eventsResponse = EventsResponse.fromJson(jsonResponse);

        developer.log(
          'Successfully fetched ${eventsResponse.data.events.length} events',
          name: 'EventService',
        );

        return eventsResponse;
      } else {
        developer.log(
          'Failed to fetch events: ${response.statusCode}',
          name: 'EventService',
          error: response.body,
        );
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching events',
        name: 'EventService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Fetch event detail by ID
  static Future<EventDetailResponse?> getEventDetailById(
    int eventID,
    String userToken,
  ) async {
    try {
      developer.log(
        'Fetching event detail for ID: $eventID',
        name: 'EventService',
      );

      final url = ApiConstants.getEventDetailById(eventID, userToken);
      developer.log('URL: $url', name: 'EventService');

      final response = await ApiHelper.get(url);

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'EventService',
      );
      developer.log('Response body: ${response.body}', name: 'EventService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final eventDetailResponse = EventDetailResponse.fromJson(jsonResponse);

        developer.log(
          'Successfully fetched event detail: ${eventDetailResponse.data.event.eventTitle}',
          name: 'EventService',
        );

        return eventDetailResponse;
      } else {
        developer.log(
          'Failed to fetch event detail: ${response.statusCode}',
          name: 'EventService',
          error: response.body,
        );
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching event detail',
        name: 'EventService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Fetch event detail by code
  static Future<EventDetailResponse?> getEventDetailByCode(
    String eventCode,
    String userToken,
  ) async {
    try {
      developer.log(
        'Fetching event detail for code: $eventCode',
        name: 'EventService',
      );

      final url = ApiConstants.getEventDetailByCode(eventCode, userToken);
      developer.log('URL: $url', name: 'EventService');

      final response = await ApiHelper.get(url);

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'EventService',
      );
      developer.log('Response body: ${response.body}', name: 'EventService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final eventDetailResponse = EventDetailResponse.fromJson(jsonResponse);

        developer.log(
          'Successfully fetched event detail: ${eventDetailResponse.data.event.eventTitle}',
          name: 'EventService',
        );

        return eventDetailResponse;
      } else {
        developer.log(
          'Failed to fetch event detail: ${response.statusCode}',
          name: 'EventService',
          error: response.body,
        );
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching event detail',
        name: 'EventService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Fetch all user photos from all events
  static Future<GalleryPhotosResponse?> getUserPhotos(String userToken) async {
    try {
      developer.log('Fetching all user photos', name: 'EventService');

      final url = ApiConstants.getUserPhotos(userToken);
      developer.log('URL: $url', name: 'EventService');

      final response = await ApiHelper.get(url);

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'EventService',
      );
      developer.log('Response body: ${response.body}', name: 'EventService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final galleryPhotosResponse = GalleryPhotosResponse.fromJson(
          jsonResponse,
        );

        developer.log(
          'Successfully fetched ${galleryPhotosResponse.data.photos.length} photos',
          name: 'EventService',
        );

        return galleryPhotosResponse;
      } else {
        developer.log(
          'Failed to fetch user photos: ${response.statusCode}',
          name: 'EventService',
          error: response.body,
        );
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching user photos',
        name: 'EventService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Send scan request for an event
  static Future<ScanRequestResponse?> sendScanRequest(
    String userToken,
    int eventID,
  ) async {
    try {
      developer.log(
        'Sending scan request for event ID: $eventID',
        name: 'EventService',
      );

      final response = await ApiHelper.post(
        ApiConstants.sendScanRequest,
        {
          'userToken': userToken,
          'eventID': eventID,
        },
      );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'EventService',
      );
      developer.log('Response body: ${response.body}', name: 'EventService');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final scanRequestResponse = ScanRequestResponse.fromJson(jsonResponse);

        developer.log(
          'Scan request response: ${scanRequestResponse.message}',
          name: 'EventService',
        );

        return scanRequestResponse;
      } else {
        developer.log(
          'Failed to send scan request: ${response.statusCode}',
          name: 'EventService',
          error: response.body,
        );
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error sending scan request',
        name: 'EventService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
