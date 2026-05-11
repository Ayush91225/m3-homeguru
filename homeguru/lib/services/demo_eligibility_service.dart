import 'dart:convert';
import 'package:http/http.dart' as http;

class DemoEligibilityService {
  static const String baseUrl = 'https://app.homeguruworld.com/api/demo-eligibility';

  static Future<Map<String, dynamic>> checkEligibility({
    required String learnerId,
    required String tutorId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl?learnerId=$learnerId&tutorId=$tutorId');
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'canBookFreeDemo': data['canBookFreeDemo'] ?? true,
          'isPaidDemo': data['isPaidDemo'] ?? false,
          'demoPrice': data['demoPrice'] ?? 99,
          'reason': data['reason'] ?? '',
        };
      } else {
        print('Failed to check demo eligibility: ${response.statusCode}');
        return {
          'canBookFreeDemo': true,
          'isPaidDemo': false,
          'demoPrice': 99,
          'reason': 'Error checking eligibility',
        };
      }
    } catch (e) {
      print('Error checking demo eligibility: $e');
      return {
        'canBookFreeDemo': true,
        'isPaidDemo': false,
        'demoPrice': 99,
        'reason': 'Error checking eligibility',
      };
    }
  }
}
