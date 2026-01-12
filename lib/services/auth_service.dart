import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final String supabaseUrl = dotenv.env["SUPABASE_URL"].toString();
  static final String anonKey = dotenv.env["SUPABASE_ANON"].toString();

  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthday,
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
    final monthDifference = td.month - bd.month;
    final dayDifference = td.day - bd.day;

    if (monthDifference < 0 || (monthDifference == 0 && dayDifference < 0)) {
      age--;
    }

    if (age < 18) {
      return {"success": false, "data": "Age Invalid"};
    }

    return {"success": true, "data": "Successful Sign Up"};

    // final url = Uri.parse("$baseUrl/signup");

    // final response = await http.post(
    //   url,
    //   headers: {"Content-Type": "application/json"},
    //   body: jsonEncode({
    //     "firstName": firstName,
    //     "lastName": lastName,
    //     "gender": gender,
    //     "email": email,
    //     "password": password,
    //     "birthday": birthday,
    //     "age": age,
    //     "address": address,
    //   }),
    // );

    // return jsonDecode(response.body);
  }

  // User Sign In
  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$supabaseUrl/signin");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }
}
