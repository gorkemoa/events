/// City model for location selection
class City {
  final String cityName;
  final int cityNo;

  City({
    required this.cityName,
    required this.cityNo,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityName: json['cityName'] as String,
      cityNo: json['cityNo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'cityNo': cityNo,
    };
  }
}

/// Cities response model
class CitiesResponse {
  final bool error;
  final bool success;
  final CitiesData? data;
  final String? statusCode;

  CitiesResponse({
    required this.error,
    required this.success,
    this.data,
    this.statusCode,
  });

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    return CitiesResponse(
      error: json['error'] as bool,
      success: json['success'] as bool,
      data: json['data'] != null 
          ? CitiesData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      statusCode: json['200'] as String?,
    );
  }

  bool get isSuccess => success && !error;
}

/// Cities data model
class CitiesData {
  final List<City> cities;

  CitiesData({
    required this.cities,
  });

  factory CitiesData.fromJson(Map<String, dynamic> json) {
    final citiesList = json['cities'] as List<dynamic>;
    return CitiesData(
      cities: citiesList
          .map((item) => City.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
