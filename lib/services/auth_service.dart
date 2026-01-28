import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutribin_application/utils/helpers.dart';

final String restUser = dotenv.env["RAILWAY_USER"].toString();
final String restServer = dotenv.env["RAILWAY_SERVER"].toString();
final String googleClient = dotenv.env["GOOGLE_CLIENT_ID"].toString();
final String supabaseUrl = dotenv.env["SUPABASE_URL"].toString();
final String anonKey = dotenv.env["SUPABASE_ANON"].toString();

class AuthUtility {
  static Future<Map<String, dynamic>> sendEmailVerification({
    required String email,
  }) async {
    try {
      final url = Uri.parse("$restUser/user/send-verification");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['ok'] == true) {
          return {
            "ok": true,
            "message": data['message'] ?? 'Verification code sent',
          };
        }
      }

      return ResponseUtility.invalid(
        data['message'] ?? 'Failed to send verification code',
      );
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
    }
  }

  static Future<Map<String, dynamic>> verifyEmail({
    required String code,
  }) async {
    try {
      final url = Uri.parse("$restUser/user/verify-email");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"verificationCode": code}),
      );

      final data = jsonDecode(response.body);

      if (data["ok"] != true) {
        return ResponseUtility.invalid(data["error"]);
      }

      return {"ok": true, "message": "Code verified successfully"};
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
    }
  }

  static Future<Map<String, dynamic>> sendContactVerification({
    required String contact,
  }) async {
    try {
      final url = Uri.parse("$restServer/staff/phone/request");

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
            "ok": true,
            "code": data['code'],
            "message": data['message'] ?? 'Verification sms code sent',
          };
        }
      }

      return ResponseUtility.invalid(
        data['message'] ?? 'Failed to send sms code',
      );
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
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
            "ok": true,
            "message": data['message'] ?? 'Password Changed Successfully',
          };
        }
      } else {
        return {
          "ok": false,
          "message": data["message"] ?? "Password Reset Failed",
        };
      }
      return {"ok": false, "message": "Password Reset Failed"};
    } catch (e) {
      return {"ok": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String userId,
    required String code,
  }) async {
    try {
      final url = Uri.parse("$supabaseUrl/functions/v1/verify-email-otp");

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
            "ok": true,
            "message": data['message'] ?? 'Email verified successfully',
          };
        }
      }

      return {
        "ok": false,
        "message": data['message'] ?? 'Invalid verification code',
      };
    } catch (e) {
      return {"ok": false, "message": e.toString()};
    }
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
        return {"ok": false, "data": "User ID not found"};
      }

      final url = Uri.parse("$restUser/settings/$userId");

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
        return {"ok": true, "data": data["user"]};
      } else {
        return {"ok": false, "data": data["error"] ?? "Update failed"};
      }
    } catch (e) {
      return {"ok": false, "data": e.toString()};
    }
  }

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
