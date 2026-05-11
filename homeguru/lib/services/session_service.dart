import 'dart:convert';
import 'package:http/http.dart' as http;

class SessionService {
  static const String baseUrl = 'https://app.homeguruworld.com/api/sessions';

  static Future<List<dynamic>> fetchSessions({
    String? tutorId,
    String? learnerId,
    String? status,
  }) async {
    try {
      final params = <String, String>{};
      if (tutorId != null) params['tutorId'] = tutorId;
      if (learnerId != null) params['learnerId'] = learnerId;
      if (status != null) params['status'] = status;
      params['_t'] = DateTime.now().millisecondsSinceEpoch.toString();

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['sessions'] ?? [];
      } else {
        print('Failed to fetch sessions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching sessions: $e');
      return [];
    }
  }
}
