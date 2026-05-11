import 'dart:convert';
import 'package:http/http.dart' as http;

class LearnerProfileService {
  static const String baseUrl = 'https://app.homeguruworld.com/api/learner/profile';

  static Future<Map<String, dynamic>?> fetchProfile(String learnerId) async {
    try {
      final uri = Uri.parse('$baseUrl?learnerId=$learnerId&_t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['profile'];
      } else {
        print('Failed to fetch learner profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching learner profile: $e');
      return null;
    }
  }

  static Future<bool> updateProfile(String learnerId, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'learnerId': learnerId,
          ...updates,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update learner profile: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating learner profile: $e');
      return false;
    }
  }
}
