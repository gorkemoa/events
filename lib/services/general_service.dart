import 'dart:convert';
import 'dart:developer' as developer;
import '../models/city_models.dart';
import 'api_helper.dart';
import 'constants.dart';

/// General service for handling general operations
class GeneralService {
  /// Get all cities
  /// 
  /// Returns [CitiesResponse] with cities list
  Future<CitiesResponse> getAllCities() async {
    try {
      developer.log('🏙️ Get All Cities Request', name: 'GeneralService');
      developer.log('URL: ${ApiConstants.getAllCities}', name: 'GeneralService');

      final response = await ApiHelper.get(
        ApiConstants.getAllCities,
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'GeneralService');
      developer.log('📥 Response Body: ${response.body}', name: 'GeneralService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final citiesResponse = CitiesResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${citiesResponse.success}', name: 'GeneralService');
      developer.log('📊 Cities count: ${citiesResponse.data?.cities.length ?? 0}', name: 'GeneralService');
      
      return citiesResponse;
    } catch (e, stackTrace) {
      developer.log('❌ Exception occurred', name: 'GeneralService', error: e, stackTrace: stackTrace);
      return CitiesResponse(
        error: true,
        success: false,
      );
    }
  }
}
