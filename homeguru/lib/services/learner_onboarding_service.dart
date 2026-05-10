import 'dart:convert';
import 'package:http/http.dart' as http;

class LearnerOnboardingService {
  static const String baseUrl = 'https://app.homeguruworld.com/api/onboarding/learner';

  /// Step 1: Register learner
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? referralCode,
  }) async {
    try {
      print('[LEARNER-REGISTER] Sending request...');
      print('[LEARNER-REGISTER] Data: firstName=$firstName, lastName=$lastName, email=$email, phone=$phone');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'referralCode': referralCode,
        }),
      );

      print('[LEARNER-REGISTER] Response status: ${response.statusCode}');
      print('[LEARNER-REGISTER] Response body: ${response.body}');

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        print('[LEARNER-REGISTER] Success! LearnerId: ${result['data']['learnerId']}');
        return {
          'success': true,
          'learnerId': result['data']['learnerId'],
          'token': result['data']['token'],
          'currentStep': result['data']['currentStep'],
        };
      } else {
        print('[LEARNER-REGISTER] Failed: ${result['error']}');
        return {
          'success': false,
          'error': result['error'] ?? result['details'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('[LEARNER-REGISTER] Exception: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 2: Update profile
  static Future<Map<String, dynamic>> updateProfile({
    required String learnerId,
    required String name,
    required String dob,
    required String gender,
    required String language,
    required String type,
    required String country,
    required String state,
    required String city,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'learnerId': learnerId,
          'name': name,
          'dob': dob,
          'gender': gender,
          'language': language,
          'type': type,
          'country': country,
          'state': state,
          'city': city,
        }),
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

  /// Step 3: Update education details
  static Future<Map<String, dynamic>> updateEducation({
    required String learnerId,
    required String type,
    String? board,
    String? studentClass,
    String? school,
    String? field,
    String? year,
  }) async {
    try {
      final Map<String, dynamic> educationData = {
        'learnerId': learnerId,
        'type': type,
      };

      if (type == 'school') {
        educationData['board'] = board;
        educationData['class'] = studentClass;
        educationData['school'] = school;
      } else if (type == 'college') {
        educationData['field'] = field;
        educationData['year'] = year;
      } else if (type == 'aspirant') {
        educationData['field'] = field;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/education'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(educationData),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Education update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 4: Update subject preferences
  static Future<Map<String, dynamic>> updateSubjects({
    required String learnerId,
    required List<String> subjects,
    String? category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subjects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'learnerId': learnerId,
          'subjects': subjects,
          'category': category,
        }),
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

  /// Update referral source
  static Future<Map<String, dynamic>> updateSource({
    required String learnerId,
    required String source,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/source'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'learnerId': learnerId,
          'source': source,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Source update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Step 5: Update interests and complete onboarding
  static Future<Map<String, dynamic>> updateInterests({
    required String learnerId,
    required List<String> interests,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'learnerId': learnerId,
          'interests': interests,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Interests update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get learner onboarding data
  static Future<Map<String, dynamic>> getLearnerData(String learnerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/register?learnerId=$learnerId'),
        headers: {'Content-Type': 'application/json'},
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
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
