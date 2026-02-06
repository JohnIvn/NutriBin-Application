import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutribin_application/utils/helpers.dart';
import 'package:nutribin_application/utils/response_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String restUser = dotenv.env["RAILWAY_USER"].toString();
final String restServer = dotenv.env["RAILWAY_SERVER"].toString();
final String googleClient = dotenv.env["GOOGLE_CLIENT_ID"].toString();
final String supabaseUrl = dotenv.env["SUPABASE_URL"].toString();
final String anonKey = dotenv.env["SUPABASE_ANON"].toString();

class AvatarService {
  static Future<Map<String, dynamic>> uploadPfp() async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null || userId.isEmpty) {
        return Error.errorResponse("Please login first");
      }

      final url = Uri.parse("$restUser/settings/$userId/photo");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
        body: jsonEncode({"file": "FAKE FILE BUFFER"}), // TODO
      );

      final result = jsonDecode(response.body);

      if (result["ok"] != true) {
        return Error.errorResponse(
          result["message"] ??
              result["error"] ??
              "Failed to upload profile picture, try again later",
        );
      }

      return {
        "ok": true,
        "message": result["message"] ?? "Successfully uploaded profile picture",
        "data": result["data"],
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getPfp() async {
    try {
      String? userId = await PreferenceUtility.getUserId();
      if (userId == null || userId.isEmpty) {
        return Error.errorResponse("Please login first");
      }

      final url = Uri.parse("$restUser/settings/$userId/photo");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
          "apikey": anonKey,
        },
      );

      final result = jsonDecode(response.body);

      if (result["ok"] != true) {
        return Error.errorResponse(
          result["message"] ??
              result["error"] ??
              "Failed to fetch profile picture, try again later",
        );
      }

      return {
        "ok": true,
        "message": result["message"] ?? "Successfully uploaded profile picture",
        "data": result["data"],
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }
}
