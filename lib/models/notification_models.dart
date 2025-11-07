/// Response model for notifications
class NotificationsResponse {
  final bool error;
  final bool success;
  final NotificationsData? data;
  final String? errorMessage;
  final String statusCode;

  NotificationsResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? NotificationsData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Notifications data wrapper
class NotificationsData {
  final List<NotificationItem> notifications;

  NotificationsData({required this.notifications});

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
      notifications: (json['notifications'] as List?)
          ?.map((item) => NotificationItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

/// Notification item model
class NotificationItem {
  final int id;
  final String title;
  final String body;
  final String type;
  final int typeId;
  final String url;
  final bool isRead;
  final String createDate;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.typeId,
    required this.url,
    required this.isRead,
    required this.createDate,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      typeId: json['type_id'] ?? 0,
      url: json['url'] ?? '',
      isRead: json['isRead'] ?? false,
      createDate: json['create_date'] ?? '',
    );
  }
}
