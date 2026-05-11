import 'dart:convert';
import 'package:http/http.dart' as http;

class PaidPaymentService {
  static const String baseUrl = 'https://app.homeguruworld.com/api/paid-payment';

  /// Fetch pending payments for learner
  static Future<List<Map<String, dynamic>>> fetchPendingPayments({
    required String learnerId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?learnerId=$learnerId'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['requests'] ?? []);
      } else {
        throw Exception('Failed to fetch pending payments: ${response.body}');
      }
    } catch (e) {
      print('Error fetching pending payments: $e');
      rethrow;
    }
  }

  /// Create Razorpay order for paid class
  static Future<Map<String, dynamic>> createOrder({
    required String requestId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': requestId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  /// Verify payment and create session series
  static Future<Map<String, dynamic>> verifyPayment({
    required String requestId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': requestId,
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify payment: ${response.body}');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      rethrow;
    }
  }
}
