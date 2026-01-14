import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final String supabaseUrl = dotenv.env["SUPABASE_URL"].toString();
  static final String anonKey = dotenv.env["SUPABASE_ANON"].toString();
  // static final String supabaseUrl = "https://mtfbnszjdqpjpuigvgoh.supabase.co";
  // static final String anonKey ="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10ZmJuc3pqZHFwanB1aWd2Z29oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzMTE1MTAsImV4cCI6MjA4MTg4NzUxMH0.OQFKEKwScPyCUa63dBI5nm7rDFhB0q12O5OKYIFyaQY";

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

    final url = Uri.parse("$supabaseUrl/functions/v1/signup");

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
    final url = Uri.parse("$supabaseUrl/functions/v1/signin");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }
}
