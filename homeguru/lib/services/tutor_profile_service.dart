import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TutorProfileService {
  static const String _baseUrl = 'https://app.homeguruworld.com/api/tutor/profile';
  static const String _uploadUrl = 'https://app.homeguruworld.com/api/upload';

  /// Fetch full tutor data
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

  /// Upload a file to S3 and return the URL
  static Future<String?> uploadFile(File file, String folder) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['folder'] = folder;
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final result = jsonDecode(body);
      if (response.statusCode == 200 && result['success'] == true) {
        return result['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
