import 'dart:convert';
import 'api_helper.dart';
import 'constants.dart';

class PoliciesService {
  /// Get Membership Agreement
  static Future<Map<String, dynamic>?> getMembershipAgreement() async {
    try {
      final url =
          '${ApiConstants.baseUrl}service/general/general/contracts/membershipAgreement';
      final response = await ApiHelper.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          return json['data'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching membership agreement: $e');
      return null;
    }
  }

  /// Get Privacy Policy
  static Future<Map<String, dynamic>?> getPrivacyPolicy() async {
    try {
      final url =
          '${ApiConstants.baseUrl}service/general/general/contracts/privacyPolicy';
      final response = await ApiHelper.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          return json['data'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching privacy policy: $e');
      return null;
    }
  }
}
