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

  static Future<Map<String, dynamic>> createRepairRequest({
    required String machineId,
    required String description,
  }) async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      final url = Uri.parse('$restUser/mobile/repair/create');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode({
          "machineId": machineId,
          "userId": userId,
          "description": description,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        "ok": true,
        "data": data,
        "message": "Repair request created successfully",
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchRecommendedCrops({
    required String machineId,
  }) async {
    try {
      final url = Uri.parse('$restUser/mobile/recommendations/$machineId');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
      );

      final data = jsonDecode(response.body);
      print("RECOMMENDATIONS DATA: ${data.toString()}");
      return {
        "ok": data["ok"] ?? false,
        "recommendations": data["recommendations"] ?? [],
        "message": data["message"] ?? "Successfully fetched recommendations",
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchModulesStatus({
    required String machineId,
  }) async {
    try {
      final url = Uri.parse('$restUser/hardware/$machineId');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
      );

      final data = jsonDecode(response.body);

      if (data["ok"] == true && data["data"] != null) {
        final modules = data["data"]["modules"];
        // Map backend descriptive names back to short codes for the frontend
        final mappedModules = {
          'c1': modules['arduino_q'],
          'c2': modules['esp32_filter'],
          'c3': modules['esp32_servo'],
          'c4': modules['esp32_sensors'],
          's1': modules['camera'],
          's2': modules['humidity'],
          's3': modules['methane'],
          's4': modules['carbon_monoxide'],
          's5': modules['air_quality'],
          's6': modules['combustible_gasses'],
          's7': modules['npk'],
          's8': modules['moisture'],
          's9': modules['reed'],
          's10': modules['ultrasonic'],
          's11': modules['weight'],
          'm1': modules['servo_a'],
          'm2': modules['servo_b'],
          'm3': modules['servo_mixer'],
          'm4': modules['grinder'],
          'm5': modules['exhaust'],
        };

        return {
          "ok": true,
          "data": mappedModules,
          "message": data["message"] ?? "Successfully fetched module status",
        };
      }

      return data;
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchNotifications({
    required String machineId,
  }) async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      final url = Uri.parse(
        '$restUser/mobile/machine/notifications/$userId/$machineId',
      );

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

  static Future<Map<String, dynamic>> registerMachine({
    required String serialId,
  }) async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      final url = Uri.parse('$restUser/mobile/machine/add-machine');

      final body = {"machineSerial": serialId, "customerId": userId};
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
        return Error.errorResponse(data["error"] ?? data["message"]);
      }

      return {
        "ok": true,
        "data": data["data"],
        "message": data["message"] ?? "Successfully registered user",
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> removeMachine({
    required String machineId,
  }) async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      final url = Uri.parse(
        '$restUser/mobile/machine/delete/$userId/$machineId',
      );
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $anonKey",
        },
      );

      final data = jsonDecode(response.body);

      if (data["ok"] != true) {
        return Error.errorResponse(data["error"] ?? data["message"]);
      }

      return {
        "ok": true,
        "data": data["data"],
        "message": data["message"] ?? "Successfully registered user",
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }
}
