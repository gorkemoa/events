/// Banner model representing a banner from the API
class Banner {
  final int postID;
  final String postTitle;
  final String postExcerpt;
  final String postBody;
  final String postMainImage;
  final String postThumbImage;

  Banner({
    required this.postID,
    required this.postTitle,
    required this.postExcerpt,
    required this.postBody,
    required this.postMainImage,
    required this.postThumbImage,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      postID: json['postID'] as int,
      postTitle: json['postTitle'] as String,
      postExcerpt: json['postExcerpt'] as String,
      postBody: json['postBody'] as String,
      postMainImage: json['postMainImage'] as String,
      postThumbImage: json['postThumbImage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postID': postID,
      'postTitle': postTitle,
      'postExcerpt': postExcerpt,
      'postBody': postBody,
      'postMainImage': postMainImage,
      'postThumbImage': postThumbImage,
    };
  }
}

/// Response model for banners data
class BannersData {
  final List<Banner> banners;

  BannersData({required this.banners});

  factory BannersData.fromJson(Map<String, dynamic> json) {
    return BannersData(
      banners: (json['banners'] as List<dynamic>)
          .map((banner) => Banner.fromJson(banner as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'banners': banners.map((banner) => banner.toJson()).toList()};
  }
}

/// Response model for Get Banners API
class BannersResponse {
  final bool error;
  final bool success;
  final BannersData? data;
  final String? message;

  BannersResponse({
    required this.error,
    required this.success,
    this.data,
    this.message,
  });

  factory BannersResponse.fromJson(Map<String, dynamic> json) {
    return BannersResponse(
      error: json['error'] as bool,
      success: json['success'] as bool,
      data: json['data'] != null
          ? BannersData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}
