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
  final bool isJoined;

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
    required this.isJoined,
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
      isJoined: json['isJoined'] as bool? ?? false,
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
      'isJoined': isJoined,
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

/// Event Image model for event detail
class EventImage {
  final String mainImage;
  final String middleImage;
  final String thumbImage;

  EventImage({
    required this.mainImage,
    required this.middleImage,
    required this.thumbImage,
  });

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(
      mainImage: json['mainImage'] as String? ?? '',
      middleImage: json['middleImage'] as String? ?? '',
      thumbImage: json['thumbImage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainImage': mainImage,
      'middleImage': middleImage,
      'thumbImage': thumbImage,
    };
  }
}

/// Event Detail model with images
class EventDetail {
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
  final List<EventImage> images;

  EventDetail({
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
    required this.images,
  });

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['images'] as List? ?? [])
        .map((e) => EventImage.fromJson(e as Map<String, dynamic>))
        .toList();

    return EventDetail(
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
      images: imagesList,
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
      'images': images.map((e) => e.toJson()).toList(),
    };
  }
}

/// Event Detail Response model
class EventDetailResponse {
  final bool error;
  final bool success;
  final EventDetailData data;
  final String statusCode;

  EventDetailResponse({
    required this.error,
    required this.success,
    required this.data,
    required this.statusCode,
  });

  factory EventDetailResponse.fromJson(Map<String, dynamic> json) {
    return EventDetailResponse(
      error: json['error'] as bool,
      success: json['success'] as bool,
      data: EventDetailData.fromJson(json['data'] as Map<String, dynamic>),
      statusCode: json['200'] as String? ?? 'OK',
    );
  }
}

/// Event Detail Data model
class EventDetailData {
  final EventDetail event;
  final String message;

  EventDetailData({
    required this.event,
    required this.message,
  });

  factory EventDetailData.fromJson(Map<String, dynamic> json) {
    return EventDetailData(
      event: EventDetail.fromJson(json['event'] as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }
}

/// Gallery Photo model for all user photos
class GalleryPhoto {
  final String eventID;
  final String eventTitle;
  final String mainImage;
  final String middleImage;
  final String thumbImage;

  GalleryPhoto({
    required this.eventID,
    required this.eventTitle,
    required this.mainImage,
    required this.middleImage,
    required this.thumbImage,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    return GalleryPhoto(
      eventID: json['eventID'] as String,
      eventTitle: json['eventTitle'] as String,
      mainImage: json['mainImage'] as String,
      middleImage: json['middleImage'] as String,
      thumbImage: json['thumbImage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'eventTitle': eventTitle,
      'mainImage': mainImage,
      'middleImage': middleImage,
      'thumbImage': thumbImage,
    };
  }
}

/// Gallery Photos Response model
class GalleryPhotosResponse {
  final bool error;
  final bool success;
  final GalleryPhotosData data;
  final String statusCode;

  GalleryPhotosResponse({
    required this.error,
    required this.success,
    required this.data,
    required this.statusCode,
  });

  factory GalleryPhotosResponse.fromJson(Map<String, dynamic> json) {
    return GalleryPhotosResponse(
      error: json['error'] as bool,
      success: json['success'] as bool,
      data: GalleryPhotosData.fromJson(json['data'] as Map<String, dynamic>),
      statusCode: json['200'] as String? ?? 'OK',
    );
  }
}

/// Gallery Photos Data model
class GalleryPhotosData {
  final List<GalleryPhoto> photos;
  final String message;

  GalleryPhotosData({
    required this.photos,
    required this.message,
  });

  factory GalleryPhotosData.fromJson(Map<String, dynamic> json) {
    final photosList = (json['photos'] as List? ?? [])
        .map((e) => GalleryPhoto.fromJson(e as Map<String, dynamic>))
        .toList();

    return GalleryPhotosData(
      photos: photosList,
      message: json['message'] as String,
    );
  }
}
