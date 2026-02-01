import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutribin_application/utils/helpers.dart';
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
      // final validation = ValidationUtility.validatePayload(
      //   firstname: firstname,
      //   lastname: lastname,
      //   address: address,
      //   email: email,
      //   password: password,
      //   confirmPassword: confirmPassword,
      // );

      // if (validation["ok"] != true) {
      //   return validation;
      // }

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
        if (data["error"]) {
          throw Exception(data["error"]);
        }
        throw Exception(data["message"]);
      }
      return data;
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
    }
  }

  static Future<Map<String, dynamic>> authSignIn({
    required String email,
    required String password,
  }) async {
    try {
      // URI Initialization
      final url = Uri.parse("$restUser/user/signin");

      // Pre-API Validation
      final isValidEmail = ValidationUtility.validateEmail(email);
      final isValidPassword = ValidationUtility.validatePassword(password);

      if (isValidEmail["ok"] != true) {
        return isValidEmail;
      }
      if (isValidPassword["ok"] != true) {
        return isValidPassword;
      }

      // Body Initialization (Signin)
      final body = {"email": email.trim(), "password": password};

      // Response (Signin)
      final responseSignin = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(responseSignin.body);

      // Error Handling (Signin)

      if (data["ok"] != true) {
        return ResponseUtility.invalid(data["error"]);
      }

      if (data["requiresMFA"] == true) {
        return {
          "ok": true,
          "requiresMFA": true,
          "userId": data["userId"] ?? data["customerId"],
        };
      }
      return {"ok": true, "data": data["user"]};
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
    }
  }

  static Future<Map<String, dynamic>> googleSignIn() async {
    try {
      final googleUser = await _instance.signIn();

      if (googleUser == null) {
        return ResponseUtility.invalid("Google sign in cancelled");
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return ResponseUtility.invalid("Failed to get Google token");
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
        throw Exception(data["message"]);
      }

      return {"ok": true, "data": data["user"], "isNewUser": data["isNewUser"]};
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
    }
  }

  static Future<Map<String, dynamic>> googleSignUp() async {
    try {
      final googleUser = await _instance.signIn();

      if (googleUser == null) {
        return ResponseUtility.invalid("Google sign in cancelled");
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return ResponseUtility.invalid("Failed to get Google token");
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
        throw Exception(data["message"]);
      }

      return {"ok": true, "data": data["user"], "isNewUser": data["isNewUser"]};
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
    }
  }

  static Future<Map<String, dynamic>> googleAuth() async {
    try {
      final googleUser = await _instance.signIn();

      if (googleUser == null) {
        return ResponseUtility.invalid("Google sign in cancelled");
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return ResponseUtility.invalid("Failed to get Google token");
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

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return ResponseUtility.invalid("Empty response from server");
      }

      final data = jsonDecode(response.body);

      if (data["ok"] != true) {
        throw Exception(data["error"] ?? "Unknown error");
      }

      return {
        "ok": true,
        "data": data["user"],
        "isNewUser": data["isNewUser"] ?? false,
      };
    } catch (e) {
      print("Error in googleAuth: $e");
      return ResponseUtility.invalid(e.toString());
    }
  }
}

class ProfileUtility {
  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final customerId = await PreferenceUtility.getUserId();

      if (customerId == null || customerId.isEmpty) {
        return ResponseUtility.invalid("Customer ID not found, please sign in");
      }

      // URI Initialization
      final url = Uri.parse("$restUser/user/$customerId");

      // Response (Signin)
      final responseSignin = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
      );

      final data = jsonDecode(responseSignin.body);

      // Error Handling (Signin)
      if (data["ok"] != true) {
        throw Exception(data["error"]);
      }

      return {"ok": true, "data": data["user"]};
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
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
        return ResponseUtility.invalid("Address must not be empty");
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

      return {"ok": true, "data": data["data"].user};
    } catch (e) {
      return ResponseUtility.invalid(e.toString());
    }
  }

  static Future<void> updatePrefs({
    String? firstname,
    String? lastname,
    String? contact,
    String? address,
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
  }
}

class SessionUtility {}
