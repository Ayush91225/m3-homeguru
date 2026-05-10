import 'dart:convert';
import 'package:http/http.dart' as http;

class TutorProfileService {
  static const String _baseUrl = 'https://app.homeguruworld.com/api/tutor/profile';

  /// Fetch tutor profile data for edit screen
  static Future<Map<String, dynamic>> getTutorProfile(String tutorId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?tutorId=$tutorId'),
        headers: {'Content-Type': 'application/json'},
      );
      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true, 'data': result['data']};
      }
      return {'success': false, 'error': result['error'] ?? 'Failed to fetch profile'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Update tutor profile fields (partial update)
  /// [fields] can contain: profilePhoto, experience, rates, youtubeVideoLink, availability
  static Future<Map<String, dynamic>> updateProfile(String tutorId, Map<String, dynamic> fields) async {
    try {
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, ...fields}),
      );
      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return {
          'success': true,
          'isComplete': result['data']?['isComplete'] ?? false,
          'isActive': result['data']?['isActive'] ?? false,
        };
      }
      return {'success': false, 'error': result['error'] ?? 'Update failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
