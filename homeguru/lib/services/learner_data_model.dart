import 'dart:convert';
import 'package:http/http.dart' as http;

class LearnerDataModel {
  static const _baseUrl = 'https://app.homeguruworld.com/api';

  /// Fetch active & verified tutors
  static Future<List<Map<String, dynamic>>> fetchTutors({
    int limit = 50,
    String? subject,
    String? board,
    String? grade,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
        if (subject != null) 'subject': subject,
        if (board != null) 'board': board,
        if (grade != null) 'grade': grade,
      };

      final uri = Uri.parse('$_baseUrl/tutors').replace(queryParameters: params);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return List<Map<String, dynamic>>.from(result['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching tutors: $e');
      return [];
    }
  }

  /// Map API tutor to widget format
  static Map<String, dynamic> mapTutorForWidget(Map<String, dynamic> apiTutor) {
    return {
      'id': apiTutor['tutorId'],
      'name': apiTutor['name'],
      'image': apiTutor['profilePhoto'],
      'verified': apiTutor['isVerified'] == true,
      'rating': apiTutor['rating'] ?? 0.0,
      'reviews': apiTutor['reviewCount'] ?? 0,
      'students': 0, // Not in API yet
      'location': apiTutor['location'] ?? '',
      'experience': apiTutor['experience'] ?? '',
      'responseTime': '< 1 hour', // Mock for now
      'subjects': (apiTutor['subjects'] as List?)?.map((s) => {
        'name': s,
        'hourlyRate': apiTutor['hourlyRate'] ?? 0,
      }).toList() ?? [],
    };
  }
}
