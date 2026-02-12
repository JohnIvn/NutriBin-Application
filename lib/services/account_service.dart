import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:nutribin_application/utils/response_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final String restUser = dotenv.env["RAILWAY_USER"].toString();
final String restServer = dotenv.env["RAILWAY_SERVER"].toString();
final String googleClient = dotenv.env["GOOGLE_CLIENT_ID"].toString();
final String anonKey = dotenv.env["SUPABASE_ANON"].toString();

final GoogleSignIn _instance = GoogleSignIn(
  clientId: googleClient,
  scopes: ['email', 'profile'],
);

class AccountUtility {
  static Future<Map<String, dynamic>> authSignUp({
    required String firstname,
    required String lastname,
    required String address,
    required String email,
    required String password,
    required String confirmPassword,
    required String emailVerification,
  }) async {
    try {
      final url = Uri.parse("$restUser/user/signup");
      final validation = ValidationUtility.validatePayload(
        firstname: firstname,
        lastname: lastname,
        address: address,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (validation["ok"] != true) {
        return Error.errorResponse(
          validation["message"] ?? validation["error"],
        );
      }

      final body = {
        "firstname": firstname.trim(),
        "lastname": lastname.trim(),
        "address": address.trim(),
        "email": email.trim(),
        "password": password,
        "emailVerificationCode": emailVerification,
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {"ok": true, "data": data["user"] ?? data["data"]};
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> authSignIn({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$restUser/user/mobile-signin");

      final isValidEmail = ValidationUtility.validateEmail(email);
      final isValidPassword = ValidationUtility.validatePassword(password);

      if (isValidEmail["ok"] != true) {
        return isValidEmail;
      }
      if (isValidPassword["ok"] != true) {
        return isValidPassword;
      }

      final body = {"email": email.trim(), "password": password};

      final responseSignin = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(responseSignin.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      // MFA is required - verification code has been sent
      if (data["requiresMFA"] == true) {
        return {
          "ok": true,
          "requiresMFA": true,
          "userId": data["userId"] ?? data["customerId"],
          "mfaType": data["mfaType"],
          "message": data["message"],
          "data": data["user"],
        };
      }

      // Sign-in successful - no MFA required
      return {
        "ok": true,
        "message": data["message"],
        "data": data["user"] ?? data["data"],
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> googleSignIn() async {
    try {
      final googleUser = await _instance.signIn();

      if (googleUser == null) {
        return Error.errorResponse("Google sign in cancelled");
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return Error.errorResponse("Failed to get Google token");
      }

      final url = Uri.parse("$restUser/user/google-signin");
      final token = googleAuth.idToken.toString();

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode({"credential": token}),
      );

      final data = jsonDecode(response.body);
      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {
        "ok": true,
        "data": data["user"] ?? data["data"],
        "isNewUser": data["isNewUser"],
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> googleSignUp() async {
    try {
      final googleUser = await _instance.signIn();

      if (googleUser == null) {
        return Error.errorResponse("Google sign in cancelled");
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return Error.errorResponse("Failed to get Google token");
      }

      final url = Uri.parse("$restUser/user/google-signup");
      final token = googleAuth.idToken.toString();

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode({"credential": token}),
      );

      final data = jsonDecode(response.body);
      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {
        "ok": true,
        "data": data["user"] ?? data["data"],
        "isNewUser": data["isNewUser"],
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> googleAuth() async {
    try {
      final googleUser = await _instance.signIn();

      if (googleUser == null) {
        return Error.errorResponse("Google sign in cancelled");
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return Error.errorResponse("Failed to get Google token");
      }

      final url = Uri.parse("$restUser/user/google-auth");
      final token = googleAuth.idToken.toString();

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode({"credential": token}),
      );

      if (response.body.isEmpty) {
        return Error.errorResponse("Empty response from server");
      }

      final data = jsonDecode(response.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {
        "ok": true,
        "data": data["user"],
        "isNewUser": data["isNewUser"] ?? false,
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> checkEmail({
    required String email,
  }) async {
    try {
      final url = Uri.parse("$restUser/user/check-email/$email");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
      );

      if (response.body.isEmpty) {
        return Error.errorResponse("Empty response from server");
      }

      final data = jsonDecode(response.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {"ok": true, "available": data["available"]};
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }
}

class ProfileUtility {
  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final customerId = await PreferenceUtility.getUserId();

      if (customerId == null || customerId.isEmpty) {
        return Error.errorResponse("Customer ID not found, please sign in");
      }

      final url = Uri.parse("$restUser/user/$customerId");

      final responseSignin = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
      );

      final data = jsonDecode(responseSignin.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["message"] ?? data["error"]);
      }

      return {"ok": true, "data": data["user"] ?? data["data"]};
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? firstname,
    String? lastname,
    String? address,
    String? contact,
  }) async {
    try {
      // Pre-API Validation
      final isValidFirstname = ValidationUtility.validateName(
        firstname.toString(),
      );
      final isValidLastname = ValidationUtility.validateName(
        lastname.toString(),
      );
      final isValidContact = ValidationUtility.validateContact(
        contact.toString(),
      );

      if (isValidFirstname["ok"] != true) {
        return isValidFirstname;
      }
      if (isValidLastname["ok"] != true) {
        return isValidLastname;
      }
      if (address.toString().isEmpty) {
        return Error.errorResponse("Address must not be empty");
      }
      if (isValidContact["ok"] != true) {
        return isValidFirstname;
      }

      // URL
      final url = Uri.parse("$restUser/user/update");

      // Body
      final body = {firstname, lastname, contact, address};

      // Response (Signin)
      final responseSignin = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(responseSignin.body);

      // Error Handling
      if (data["ok"] != true) {
        throw Exception(data["message"]);
      }

      await updatePrefs(
        firstname: firstname,
        lastname: lastname,
        contact: contact,
        address: address,
      );

      return {"ok": true, "data": data["user"]};
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<void> updatePrefs({
    String? firstname,
    String? lastname,
    String? contact,
    String? address,
    bool? mfa,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (firstname != null) {
      await prefs.setString('firstName', firstname);
    }
    if (lastname != null) {
      await prefs.setString('lastName', lastname);
    }
    if (contact != null) {
      await prefs.setString('contact', contact);
    }
    if (address != null) {
      await prefs.setString('address', address);
    }
    if (mfa != null) {
      await prefs.setBool('mfa', mfa);
    }
  }
}
