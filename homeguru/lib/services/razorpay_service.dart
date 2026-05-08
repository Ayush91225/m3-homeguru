import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorpayService {
  static const String keyId = 'rzp_test_SaRLWC9tRdlI8U';
  static const String keySecret = 'W66t7QTrO4nF2fV4d276CcU6';
  static const String baseUrl = 'https://api.razorpay.com/v1';

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
    required int amount, // Amount in paise (e.g., 50000 = ₹500)
    required String receipt,
    String currency = 'INR',
    Map<String, dynamic>? notes,
  }) async {
    try {
      final auth = base64Encode(utf8.encode('$keyId:$keySecret'));
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'receipt': receipt,
          'notes': notes ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Order creation failed: ${response.body}');
        return null;
      }
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
