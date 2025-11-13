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
      developer.log('Fetching events for user token: $userToken, city: $city, searchText: $searchText', name: 'EventService');
      
      final url = ApiConstants.getAllEvents(userToken, city: city, searchText: searchText);
      developer.log('URL: $url', name: 'EventService');
      
      final response = await ApiHelper.get(url);
      
      developer.log('Response status: ${response.statusCode}', name: 'EventService');
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
}
