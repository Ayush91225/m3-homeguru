import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestService {
  static const String baseUrl = 'https://app.homeguruworld.com/api/requests';

  static Future<Map<String, dynamic>> createRequest({
    required String learnerId,
    required String tutorId,
    required String type,
    required String subject,
    String? board,
    String? grade,
    String? level,
    String? preferredSlot,
    List<int>? preferredDays,
    String? preferredTime,
    int? classesPerWeek,
    int? months,
    int? totalSessions,
    int? perHourRate,
    int? totalPrice,
    String? message,
    required String studentName,
    required String studentImage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'learnerId': learnerId,
          'tutorId': tutorId,
          'type': type,
          'subject': subject,
          'board': board,
          'grade': grade,
          'level': level,
          'preferredSlot': preferredSlot,
          'preferredDays': preferredDays,
          'preferredTime': preferredTime,
          'classesPerWeek': classesPerWeek,
          'months': months,
          'totalSessions': totalSessions,
          'perHourRate': perHourRate,
          'totalPrice': totalPrice,
          'message': message,
          'studentName': studentName,
          'studentImage': studentImage,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create request: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating request: $e');
    }
  }

  static Future<List<dynamic>> fetchRequests({
    String? tutorId,
    String? learnerId,
    String? type,
    String? status,
  }) async {
    try {
      final params = <String, String>{};
      if (tutorId != null) params['tutorId'] = tutorId;
      if (learnerId != null) params['learnerId'] = learnerId;
      if (type != null) params['type'] = type;
      if (status != null) params['status'] = status;

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['requests'] ?? [];
      } else {
        throw Exception('Failed to fetch requests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  static Future<Map<String, dynamic>> updateRequestStatus({
    required String requestId,
    required String type,
    required String action,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': requestId,
          'type': type,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update request: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating request: $e');
    }
  }
}
