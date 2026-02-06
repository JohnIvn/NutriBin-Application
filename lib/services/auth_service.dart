import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
        return ResponseUtility.invalid(
          result['message'] ?? 'Failed to send verification code',
        );
      }

      return {
        "ok": true,
        "message": result['message'] ?? 'Verification code sent',
      };
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
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null) {
        return {"ok": false, "data": "User ID not found"};
      }
      // final url = Uri.parse("$restServer/staff/phone/request");
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
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      if (result["ok"] != true) {
        return ResponseUtility.invalid(result["message"]);
      }
      return {
        "ok": true,
        "message": result['message'] ?? 'Password Changed Successfully',
      };
    } catch (e) {
      return {"ok": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (password != confirmPassword) {
        return ResponseUtility.invalid(
          "Password and Confirm Password must match",
        );
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["ok"] == true) {
          return {"ok": true, "data": data["message"]};
        } else {
          return {"ok": false, "data": data["message"] ?? "Update failed"};
        }
      } else {
        // Handle non-200 responses
        final errorData = jsonDecode(response.body);
        return {
          "ok": false,
          "data":
              errorData["message"] ??
              "Update failed with status ${response.statusCode}",
        };
      }
    } catch (e) {
      print("Error: $e");
      return {"ok": false, "data": e.toString()};
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["ok"] == true) {
          return {"ok": true, "data": data["user"]};
        } else {
          return {"ok": false, "data": data["message"] ?? "Update failed"};
        }
      } else {
        // Handle non-200 responses
        final errorData = jsonDecode(response.body);
        return {
          "ok": false,
          "data":
              errorData["message"] ??
              "Update failed with status ${response.statusCode}",
        };
      }
    } catch (e) {
      print("Error: $e");
      return {"ok": false, "data": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyContact({
    required String newPhone,
    required String code,
  }) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null) {
        return {"ok": false, "data": "User ID not found"};
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
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data["ok"] == true) {
          return {"ok": true, "data": data["user"]};
        } else {
          return {"ok": false, "data": data["message"] ?? "Update failed"};
        }
      } else {
        // Handle non-200 responses
        final errorData = jsonDecode(response.body);
        return {
          "ok": false,
          "data":
              errorData["message"] ??
              "Update failed with status ${response.statusCode}",
        };
      }
    } catch (e) {
      print("Error: $e");
      return {"ok": false, "data": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> toggleMfa({required String type}) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null) {
        return {"ok": false, "message": "User ID not found"};
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

      final response = jsonDecode(result.body) as Map<String, dynamic>;

      if (response["ok"] != true) {
        return ResponseUtility.invalid(
          response["message"] ?? response["error"],
        );
      }
      return {
        "ok": true,
        "message": response["message"] ?? "MFA settings updated successfully",
        "data": response["mfaType"],
      };
    } catch (e) {
      return {"ok": false, "message": "An error occurred: ${e.toString()}"};
    }
  }

  static Future<Map<String, dynamic>> fetchMfa({String? uid}) async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      final url;
      if (userId == null) {
        return {"ok": false, "message": "User ID not found"};
      }
      if (userId.isNotEmpty) {
        url = Uri.parse("$restUser/authentication/$userId/mfa");
      } else {
        url = Uri.parse("$restUser/authentication/$uid/mfa");
      }
      print("User ID: ${userId} | UID: ${uid}");

      final result = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
      );

      final response = jsonDecode(result.body) as Map<String, dynamic>;

      if (response["ok"] != true) {
        return ResponseUtility.invalid(response["message"].toString());
      }

      return {
        "ok": true,
        "message": response["message"] ?? "MFA settings updated successfully",
        "data": response["mfaType"],
      };
    } catch (e) {
      return {"ok": false, "message": "An error occurred: ${e.toString()}"};
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
