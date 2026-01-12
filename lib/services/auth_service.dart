import 'dart:convert';
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
      return {"success": false, "data": "Password mismatch"};
    }

    final td = DateTime.now();
    final bd = DateTime.parse(birthday);

    int age = td.year - bd.year;
    if (td.month < bd.month || (td.month == bd.month && td.day < bd.day)) {
      age--;
    }

    if (age < 18) {
      return {"success": false, "data": "Age must be 18+"};
    }

    final authRes = await http.post(
      Uri.parse("$supabaseUrl/auth/v1/signup"),
      headers: {"apikey": anonKey, "Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final authData = jsonDecode(authRes.body);

    if (authRes.statusCode != 200 && authRes.statusCode != 201) {
      return {"success": false, "data": authData};
    }

    final userId = authData["user"]["id"];

    await http.post(
      Uri.parse("$supabaseUrl/rest/v1/profiles"),
      headers: {
        "apikey": anonKey,
        "Authorization": "Bearer $anonKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "id": userId,
        "first_name": firstName,
        "last_name": lastName,
        "gender": gender,
        "birthday": birthday,
        "age": age,
        "address": address,
      }),
    );

    return {"success": true, "data": "Signup successful"};
  }

  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("https://mtfbnszjdqpjpuigvgoh.supabase.co/functions/v1/signin"),
      headers: {"Content-Type": "application/json", "apikey": anonKey},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }
}
