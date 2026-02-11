import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutribin_application/utils/response_handler.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:http/http.dart' as http;

final String restUser = dotenv.env["RAILWAY_USER"].toString();
final String restServer = dotenv.env["RAILWAY_SERVER"].toString();
final String googleClient = dotenv.env["GOOGLE_CLIENT_ID"].toString();
final String anonKey = dotenv.env["SUPABASE_ANON"].toString();

class MachineService {
  static Future<Map<String, dynamic>> fetchExistingMachines() async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      final url = Uri.parse('$restUser/mobile/machine/$userId');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
      );

      final data = jsonDecode(response.body);
      print("TESTING MACHINES: ${data["data"]}");

      if (data["ok"] != true && data.data[0].toString().isEmpty) {
        await PreferenceUtility.saveMachineIds([]);
      }

      return {
        "ok": true,
        "data": data["data"],
        "message": data["message"] ?? "Successfully fetched all machines",
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchFertilizerStatus({
    required String machineId,
  }) async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      final url = Uri.parse('$restUser/mobile/machine/data/$userId/$machineId');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
      );

      final data = jsonDecode(response.body);
      print("TEST DATA: ${data.toString()}");
      return {
        "ok": true,
        "data": data["data"],
        "message": data["message"] ?? "Successfully fetched all machines",
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }
}
