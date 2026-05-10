import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tutor_onboarding_model.dart';

class TutorOnboardingService {
  static const String baseUrl = 'https://app.homeguruworld.com/api/onboarding/tutor';

  /// Save step data - intelligently routes to correct endpoint based on step
  static Future<Map<String, dynamic>> saveStep(
    int step,
    TutorOnboarding data,
  ) async {
    switch (step) {
      case 1:
        return register(data);
      case 2:
        return updateProfile(data.tutorId!, data);
      case 3:
        return completeJourney(data.tutorId!, data.get('acknowledged') ?? false);
      case 4:
        return updateSubjects(data.tutorId!, data);
      case 5:
        return submitTest(data.tutorId!, data.get('testResults'));
      case 6:
        return updatePayment(data.tutorId!, data);
      case 7:
        return updateIdVerification(data.tutorId!, data);
      case 8:
        return updateBankDetails(data.tutorId!, data);
      default:
        return {'success': false, 'error': 'Invalid step'};
    }
  }

  /// Step 1: Register tutor
  static Future<Map<String, dynamic>> register(TutorOnboarding data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {
          'success': true,
          'tutorId': result['data']['tutorId'],
          'currentStep': result['data']['currentStep'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 2: Update profile
  static Future<Map<String, dynamic>> updateProfile(
    String tutorId,
    TutorOnboarding data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, ...data.toJson()}),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Profile update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 3: Mark journey/acknowledgment as completed
  static Future<Map<String, dynamic>> completeJourney(
    String tutorId,
    bool acknowledged,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/journey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, 'acknowledged': acknowledged}),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Journey update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 3: Update subjects
  static Future<Map<String, dynamic>> updateSubjects(
    String tutorId,
    TutorOnboarding data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subjects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, ...data.toJson()}),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Subjects update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 4: Submit test results
  static Future<Map<String, dynamic>> submitTest(
    String tutorId,
    Map<String, dynamic> testResults,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tutorId': tutorId,
          'testResults': testResults,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Test submission failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 5: Update payment details
  static Future<Map<String, dynamic>> updatePayment(
    String tutorId,
    TutorOnboarding data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, ...data.toJson()}),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Payment update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 6: Update ID verification
  static Future<Map<String, dynamic>> updateIdVerification(
    String tutorId,
    TutorOnboarding data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/id-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, ...data.toJson()}),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'ID verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 7: Update bank details
  static Future<Map<String, dynamic>> updateBankDetails(
    String tutorId,
    TutorOnboarding data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bank-details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, ...data.toJson()}),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Bank details update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get tutor onboarding data
  static Future<Map<String, dynamic>> getTutorData(String tutorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/register?tutorId=$tutorId'),
        headers: {'Content-Type': 'application/json'},
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {
          'success': true,
          'data': TutorOnboarding.fromJson(result['data']),
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Failed to fetch data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Send OTP via WhatsApp
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'messageId': data['data']?['messageId'],
          'expiresIn': data['data']?['expiresIn'] ?? 600,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOTP(
    String phoneNumber,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}
