import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RazorpayService {
  static const String keyId = 'rzp_test_SaRLWC9tRdlI8U';
  static const String baseUrl = 'https://app.homeguruworld.com/api/onboarding/tutor/payment';

  late Razorpay _razorpay;

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      onSuccess(response as PaymentSuccessResponse);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      onFailure(response as PaymentFailureResponse);
    });
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (response) {
      onExternalWallet(response as ExternalWalletResponse);
    });
  }

  Future<Map<String, dynamic>?> createOrder({
    required int amount,
    required String receipt,
    String currency = 'INR',
    Map<String, dynamic>? notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutorId = prefs.getString('userId');
      
      if (tutorId == null) {
        debugPrint('TutorId not found in session');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tutorId': tutorId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {'id': data['orderId']};
        }
      }
      debugPrint('Order creation failed: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  void openCheckout({
    required String orderId,
    required int amount,
    required String name,
    required String email,
    required String contact,
    String? description,
    Map<String, dynamic>? notes,
  }) {
    final options = <String, Object>{
      'key': keyId,
      'amount': amount,
      'currency': 'INR',
      'name': 'HomeGuru',
      'description': description ?? 'Payment',
      'order_id': orderId,
      'prefill': {
        'name': name,
        'email': email,
        'contact': contact,
      },
      'notes': notes ?? {},
      'theme': {
        'color': '#6750A4',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
