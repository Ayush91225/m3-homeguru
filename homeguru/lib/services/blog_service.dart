import 'dart:convert';
import 'package:http/http.dart' as http;

class BlogService {
  static const _base = 'https://app.homeguruworld.com/api/blogs';
  static const _uploadUrl = 'https://app.homeguruworld.com/api/upload';

  /// Publish a new blog
  static Future<Map<String, dynamic>> publish({
    required String tutorId,
    required String title,
    required String body,
    required String tag,
    String? coverImagePath,
    required String authorName,
    required String authorAvatar,
  }) async {
    try {
      // Upload cover image first if provided
      String coverImageUrl = '';
      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        coverImageUrl = await _uploadCover(coverImagePath) ?? '';
      }

      final response = await http.post(
        Uri.parse(_base),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tutorId': tutorId,
          'title': title,
          'body': body,
          'tag': tag,
          'coverImageUrl': coverImageUrl,
          'authorName': authorName,
          'authorAvatar': authorAvatar,
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true, 'data': result['data']};
      }
      return {'success': false, 'error': result['error'] ?? 'Publish failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Fetch today's blogs (for stories)
  static Future<List<Map<String, dynamic>>> fetchToday() async {
    try {
      final response = await http.get(
        Uri.parse('$_base?today=true'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return List<Map<String, dynamic>>.from(result['data'] ?? []);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch all blogs (paginated)
  static Future<List<Map<String, dynamic>>> fetchAll({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_base?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return List<Map<String, dynamic>>.from(result['data'] ?? []);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch blogs by a specific tutor
  static Future<List<Map<String, dynamic>>> fetchByTutor(String tutorId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base?tutorId=$tutorId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return List<Map<String, dynamic>>.from(result['data'] ?? []);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Delete a blog
  static Future<bool> delete(String blogId, String tutorId) async {
    try {
      final response = await http.delete(
        Uri.parse(_base),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'blogId': blogId, 'tutorId': tutorId}),
      );
      final result = jsonDecode(response.body);
      return result['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Upload cover image to S3
  static Future<String?> _uploadCover(String filePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['folder'] = 'blog-covers';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final result = jsonDecode(body);
      if (response.statusCode == 200 && result['success'] == true) {
        return result['url'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
