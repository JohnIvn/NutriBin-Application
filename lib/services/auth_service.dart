import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:nutribin_application/utils/response_handler.dart';

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

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (result["ok"] != true) {
        return Error.errorResponse(
          result['message'] ?? 'Failed to send verification code',
        );
      }

      return {"ok": true, "message": result['message']};
    } catch (e) {
      return Error.errorResponse(e.toString());
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
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {
        "ok": true,
        "message": data["message"] ?? "Code verified successfully",
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> verifySms({required String code}) async {
    try {
      final url = Uri.parse("$restUser/user/verify-sms");

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
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {
        "ok": true,
        "message": data["message"] ?? "Code verified successfully",
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> sendContactVerification({
    required String contact,
  }) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null) {
        Error.errorResponse("Please Login First");
      }

      final url = Uri.parse("$restUser/settings/$userId/phone/verify/request");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"newPhone": contact}),
      );

      final data = jsonDecode(response.body);

      if (data['ok'] != true) {
        return Error.errorResponse(
          data['message'] ?? data["error"] ?? 'Failed to send sms code',
        );
      }

      return {
        "ok": true,
        "code": data['code'],
        "message": data['message'] ?? 'Verification sms code sent',
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
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
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }
      return {
        "ok": true,
        "message": data['message'] ?? 'Password Changed Successfully',
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (password != confirmPassword) {
        return Error.errorResponse("Password and Confirm Password must match");
      }

      final url = Uri.parse("$restUser/user/update-password");

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"email": email, "newPassword": password}),
      );

      final data = jsonDecode(response.body);
      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {"ok": true, "message": data["message"]};
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required String firstName,
    required String lastName,
    required String contact,
    required String address,
  }) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null) {
        return Error.errorResponse("Please Login First");
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
      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }
      return {"ok": true, "data": data["user"]};
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> verifyContact({
    required String newPhone,
    required String code,
  }) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null) {
        return Error.errorResponse("Please Login First");
      }

      final url = Uri.parse("$restUser/settings/$userId/phone/verify");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"code": code, "newPhone": newPhone}),
      );
      final data = jsonDecode(response.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }
      return {"ok": true, "data": data["user"]};
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> toggleMfa({required String type}) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null) {
        return Error.errorResponse("Please Login First");
      }

      String mfaType;
      if (type == 'disable') {
        mfaType = 'N/A';
      } else if (type == 'email') {
        mfaType = 'email';
      } else if (type == 'sms') {
        mfaType = 'sms';
      } else {
        return {"ok": false, "message": "Invalid MFA type"};
      }

      final url = Uri.parse("$restUser/authentication/$userId/mfa");

      final result = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"mfaType": mfaType}),
      );

      final data = jsonDecode(result.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }
      return {
        "ok": true,
        "message": data["message"] ?? "MFA settings updated successfully",
        "data": data["mfaType"],
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchMfa({String? uid}) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      Uri url;
      if (userId.toString().isNotEmpty ||
          userId != null ||
          userId.toString() != "null") {
        url = Uri.parse("$restUser/authentication/$userId/mfa");
      } else {
        url = Uri.parse("$restUser/authentication/$uid/mfa");
      }

      final result = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
      );

      final data = jsonDecode(result.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {
        "ok": true,
        "message": data["message"] ?? "MFA settings updated successfully",
        "data": data["mfaType"],
      };
    } catch (e) {
      return {"ok": false, "message": "An error occurred: ${e.toString()}"};
    }
  }

  static Future<Map<String, dynamic>> verifyMfa({
    required String type,
    required String otp,
  }) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      Uri url;
      dynamic data;

      if (userId == null) {
        return Error.errorResponse("Please Login First");
      }
      if (type == "sms") {
        url = Uri.parse("$restUser/settings/$userId/phone/verify");
        final result = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $anonKey",
            "apikey": anonKey,
          },
        );
        data = jsonDecode(result.body);
        if (data["ok"] != true) {
          return Error.errorResponse(data["message"] ?? data["data"]);
        }
      } else if (type == "email") {
        url = Uri.parse("$restUser/user/verify-email");
        final result = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $anonKey",
            "apikey": anonKey,
          },
          body: jsonEncode({"verificationCode": otp}),
        );
        data = jsonDecode(result.body);
        if (data["ok"] != true) {
          return Error.errorResponse(data["message"] ?? data["data"]);
        }
      } else {
        return Error.errorResponse("Invalid mfa type");
      }

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {
        "ok": true,
        "message": data["message"] ?? "MFA settings updated successfully",
        "data": data["mfaType"],
      };
    } catch (e) {
      return {"ok": false, "message": "An error occurred: ${e.toString()}"};
    }
  }

  // Ivan did this (IDK how it works)
  Future<void> startServer() async {
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
