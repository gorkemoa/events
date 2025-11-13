/// Event model representing an event from the API
class Event {
  final int eventID;
  final String eventCode;
  final String eventTitle;
  final String eventCity;
  final String eventDistrict;
  final String eventLocation;
  final String eventImage;
  final String eventStartDate;
  final String eventEndDate;
  final String eventStatus;
  final int imageCount;
  final bool isPrivate;

  Event({
    required this.eventID,
    required this.eventCode,
    required this.eventTitle,
    required this.eventCity,
    required this.eventDistrict,
    required this.eventLocation,
    required this.eventImage,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.eventStatus,
    required this.imageCount,
    required this.isPrivate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventID: json['eventID'] as int,
      eventCode: json['eventCode'] as String,
      eventTitle: json['eventTitle'] as String,
      eventCity: json['eventCity'] as String,
      eventDistrict: json['eventDistrict'] as String,
      eventLocation: json['eventLocation'] as String,
      eventImage: json['eventImage'] as String,
      eventStartDate: json['eventStartDate'] as String,
      eventEndDate: json['eventEndDate'] as String,
      eventStatus: json['eventStatus'] as String,
      imageCount: json['imageCount'] as int,
      isPrivate: json['isPrivate'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'eventCode': eventCode,
      'eventTitle': eventTitle,
      'eventCity': eventCity,
      'eventDistrict': eventDistrict,
      'eventLocation': eventLocation,
      'eventImage': eventImage,
      'eventStartDate': eventStartDate,
      'eventEndDate': eventEndDate,
      'eventStatus': eventStatus,
      'imageCount': imageCount,
      'isPrivate': isPrivate,
    };
  }
}

/// Events response model
class EventsResponse {
  final bool error;
  final bool success;
  final EventsData data;

  EventsResponse({
    required this.error,
    required this.success,
    required this.data,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      error: json['error'] as bool,
      success: json['success'] as bool,
      data: EventsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// Events data model
class EventsData {
  final List<Event> events;
  final String message;

  EventsData({
    required this.events,
    required this.message,
  });

  factory EventsData.fromJson(Map<String, dynamic> json) {
    final eventsList = (json['events'] as List)
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();

    return EventsData(
      events: eventsList,
      message: json['message'] as String,
    );
  }
}
