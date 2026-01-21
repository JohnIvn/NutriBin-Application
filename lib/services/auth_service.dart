import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutribin_application/utils/helpers.dart';

class AuthService {
  static final String restUrl = dotenv.env["REST_URL"].toString();
  static final String restBackend = dotenv.env["BACKEND_URL"].toString();
  static final String supabaseUrl = dotenv.env["SUPABASE_URL"].toString();
  static final String anonKey = dotenv.env["SUPABASE_ANON"].toString();

  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String address,
    required String email,
    required String password,
    required String confirmPassword,
    required String emailVerificationCode,
  }) async {
    // Basic frontend validation
    if (firstName.trim().isEmpty) {
      return {"success": false, "message": "Firstname is required"};
    }
    if (lastName.trim().isEmpty) {
      return {"success": false, "message": "Lastname is required"};
    }
    if (email.trim().isEmpty) {
      return {"success": false, "message": "Email is required"};
    }
    if (password.isEmpty) {
      return {"success": false, "message": "Password is required"};
    }
    if (password != confirmPassword) {
      return {
        "success": false,
        "message": "Password and Confirm Password mismatch",
      };
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return {"success": false, "message": "Invalid email format"};
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(emailVerificationCode.trim())) {
      return {
        "success": false,
        "message": "Email verification code must be a 6-digit number",
      };
    }

    // Prepare request body
    final body = {
      "firstname": firstName.trim(),
      "lastname": lastName.trim(),
      "address": address.trim(),
      "email": email.trim(),
      "password": password,
      "emailVerificationCode": emailVerificationCode.trim(),
    };

    final url = Uri.parse("$restUrl/user/signup");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> sendEmailVerification({
    required String email,
    String? type,
  }) async {
    try {
      final url = Uri.parse("$restUrl/user/email-verification");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"newEmail": email, "type": type}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['ok'] == true) {
          return {
            "success": true,
            "code": data['code'],
            "message": data['message'] ?? 'Verification code sent',
          };
        }
      }

      return {
        "success": false,
        "message": data['message'] ?? 'Failed to send verification code',
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> sendContactVerification({
    required String contact,
  }) async {
    try {
      final url = Uri.parse("$restBackend/staff/phone/request");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"phone": contact}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['ok'] == true) {
          return {
            "success": true,
            "code": data['code'],
            "message": data['message'] ?? 'Verification sms code sent',
          };
        }
      }

      return {
        "success": false,
        "message": data['message'] ?? 'Failed to send sms code',
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse("$supabaseUrl/functions/v1/changePassword");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"email": email, "password": newPassword}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['ok'] == true) {
          return {
            "success": true,
            "message": data['message'] ?? 'Password Changed Successfully',
          };
        }
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Password Reset Failed",
        };
      }
      return {"success": false, "message": "Password Reset Failed"};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String userId,
    required String code,
  }) async {
    try {
      final url = Uri.parse("$supabaseUrl/user/verify-email-otp");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"userId": userId, "code": code}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['ok'] == true) {
          return {
            "success": true,
            "message": data['message'] ?? 'Email verified successfully',
          };
        }
      }

      return {
        "success": false,
        "message": data['message'] ?? 'Invalid verification code',
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // TODO: Implement contact verification request
  static Future<Map<String, dynamic>> verifyContactOtp({
    required String contact,
  }) async {
    // TODO: call backend endpoint to send verification code to contact number
    return {"success": true};
  }

  // User Sign In
  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      "https://nutribin-user-backend-production.up.railway.app/user/signin",
    );
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return {
        "ok": false,
        "error":
            "Failed to connect to server. Status code: ${response.statusCode}",
      };
    }

    final data = jsonDecode(response.body);

    // Handle MFA requirement
    if (data['requiresMFA'] == true) {
      return {
        "ok": true,
        "requiresMFA": true,
        "message": data['message'],
        "userId": data['userId'],
      };
    }

    // Handle errors from backend
    if (data['ok'] == false) {
      return {"ok": false, "error": data['error'] ?? "Unknown error"};
    }

    // Successful login
    return {
      "ok": true,
      "user": data['user'], // contains safeUser fields
    };
  }

  // User Update
  static Future<Map<String, dynamic>> updateUser({
    required String firstName,
    required String lastName,
    required String contact,
    required String address,
  }) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null) {
        return {"success": false, "data": "User ID not found"};
      }

      final url = Uri.parse("$restUrl/settings/$userId");

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({
          "firstname": firstName,
          "lastname": lastName,
          "contact": contact,
          "address": address,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["ok"] == true) {
        return {"success": true, "data": data["user"]};
      } else {
        return {"success": false, "data": data["error"] ?? "Update failed"};
      }
    } catch (e) {
      return {"success": false, "data": e.toString()};
    }
  }

  // User Fetch
  static Future<Map<String, dynamic>> fetchUser() async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      final url = Uri.parse(
        "$restUrl/functions/v1/fetchAccount?customer_id=$userId",
      );
      print("USERID: $userId");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "data": e};
    }
  }

  // User Email Verification

  Future<void> startServer() async {
    // Get phone's actual IP address
    String phoneIP = '0.0.0.0';
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      if (interfaces.isNotEmpty) {
        phoneIP = interfaces.first.addresses.first.address;
      }
    } catch (e) {
      print('Error getting IP: $e');
    }

    print('Phone IP: $phoneIP');
    print('Attempting to send to Railway server...');

    try {
      final message = 'Hello from AuthService!';
      final response = await http.post(
        Uri.parse('https://nutribin-server-production.up.railway.app/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'phoneIP': phoneIP,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      print('Sent to server: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error sending to server: $e');
      print('Error type: ${e.runtimeType}');
    }
  }
}
