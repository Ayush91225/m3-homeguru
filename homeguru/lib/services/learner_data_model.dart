import 'dart:convert';
import 'package:http/http.dart' as http;

class LearnerDataModel {
  static const _baseUrl = 'https://app.homeguruworld.com/api';

  /// Fetch learner stats
  static Future<Map<String, dynamic>> fetchLearnerStats(String learnerId) async {
    try {
      final uri = Uri.parse('$_baseUrl/learner/stats?learnerId=$learnerId');
      final response = await http.get(
        uri,
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return result['stats'] ?? {};
        }
      }
      return _getDefaultStats();
    } catch (e) {
      print('Error fetching learner stats: $e');
      return _getDefaultStats();
    }
  }

  static Map<String, dynamic> _getDefaultStats() {
    return {
      'xp': 0,
      'streak': 0,
      'sessions': 0,
      'hours': 0.0,
      'tutors': 0,
      'streakData': [],
    };
  }

  /// Fetch active & verified tutors with pagination
  static Future<Map<String, dynamic>> fetchTutors({
    int limit = 20,
    String? lastKey,
    String? subject,
    String? board,
    String? grade,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
        if (lastKey != null) 'lastKey': lastKey,
        if (subject != null) 'subject': subject,
        if (board != null) 'board': board,
        if (grade != null) 'grade': grade,
      };

      final uri = Uri.parse('$_baseUrl/tutors').replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return {
            'tutors': List<Map<String, dynamic>>.from(result['data'] ?? []),
            'hasMore': result['hasMore'] ?? false,
            'lastKey': result['lastKey'],
          };
        }
      }
      return {'tutors': [], 'hasMore': false};
    } catch (e) {
      print('Error fetching tutors: $e');
      return {'tutors': [], 'hasMore': false};
    }
  }

  /// Map API tutor to widget format
  static Map<String, dynamic> mapTutorForWidget(Map<String, dynamic> apiTutor) {
    final subjects = apiTutor['subjects'] as List?;
    final rates = apiTutor['rates'] as List?;
    final languages = apiTutor['languages'] as List?;
    final availability = apiTutor['availability'];
    final location = apiTutor['location'];
    final locationStr = location is String ? location : (location is Map ? location['city'] ?? location['state'] ?? '' : '');
    
    return {
      'id': apiTutor['tutorId'] ?? '',
      'name': apiTutor['name'] ?? '',
      'image': apiTutor['profilePhoto'] ?? '',
      'verified': apiTutor['isVerified'] == true,
      'rating': (apiTutor['rating'] ?? 0).toDouble(),
      'reviews': apiTutor['reviewCount'] ?? 0,
      'students': 0, // Not in API yet
      'location': locationStr,
      'experience': apiTutor['experience']?.toString() ?? '',
      'responseTime': '< 1 hour', // Mock for now
      'subjects': (subjects ?? []).map((s) => {
        'name': s.toString(),
        'hourlyRate': apiTutor['hourlyRate'] ?? 0,
      }).toList(),
      'rates': rates ?? [],
      'languages': languages ?? [],
      'availability': availability is Map ? [availability] : (availability is List ? availability : []),
    };
  }
}
