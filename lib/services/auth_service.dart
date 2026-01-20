import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutribin_application/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String restUrl = dotenv.env["SUPABASE_URL"].toString();
  static final String anonKey = dotenv.env["SUPABASE_ANON"].toString();

  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthday,
    required String contact,
    required String address,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      return {
        "success": false,
        "data": "Password and Confirm Password mismatch",
      };
    }

    final td = DateTime.now();
    final bd = DateTime.parse(birthday);

    int age = td.year - bd.year;
    if (td.month < bd.month || (td.month == bd.month && td.day < bd.day)) {
      age--;
    }

    if (age < 18) {
      return {"success": false, "data": "Age Invalid"};
    }

    final url = Uri.parse("$restUrl/functions/v1/signup");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $anonKey",
      },
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "gender": gender,
        "birthday": birthday,
        "age": age,
        "contact": contact,
        "address": address,
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  // User Sign In
  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$restUrl/functions/v1/signin");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // User Update
  static Future<Map<String, dynamic>> updateUser({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthday,
    required String contact,
    required String address,
  }) async {
    final td = DateTime.now();
    final bd = DateTime.parse(birthday);

    int age = ProfileUtility.calculateAge(birthday);

    try {
      String? userId = await PreferenceUtility.getUserId();
      final url = Uri.parse("$restUrl/functions/v1/update");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({
          "customer_id": userId,
          "firstName": firstName,
          "lastName": lastName,
          "gender": gender,
          "birthday": birthday,
          "age": age,
          "contact": contact,
          "address": address,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "data": e};
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
