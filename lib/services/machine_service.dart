import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutribin_application/utils/response_handler.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:http/http.dart' as http;

final String restUser = dotenv.env['RAILWAY_USER'].toString();
final String restServer = dotenv.env['RAILWAY_SERVER'].toString();
final String googleClient = dotenv.env['GOOGLE_CLIENT_ID'].toString();
final String anonKey = dotenv.env['SUPABASE_ANON'].toString();

class MachineService {
  static Future<Map<String, dynamic>> fetchExistingMachines() async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse('Customer ID Required');
      }
      final url = Uri.parse('$restUser/mobile/machine/$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);

      return {
        'ok': true,
        'data': data['data'],
        'message': data['message'] ?? 'Successfully fetched all machines',
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
        return Error.errorResponse('Customer ID Required');
      }
      final url = Uri.parse('$restUser/mobile/machine/data/$userId/$machineId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'ok': true,
        'data': data['data'],
        'message': data['message'] ?? 'Successfully fetched all machines',
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
        return Error.errorResponse('Customer ID Required');
      }
      final url = Uri.parse('$restUser/mobile/repair/create');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode({
          'machineId': machineId,
          'userId': userId,
          'description': description,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'ok': true,
        'data': data,
        'message': 'Repair request created successfully',
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchRepairRequests() async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse('Customer ID Required');
      }
      final url = Uri.parse('$restUser/mobile/repair/$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);

      if (data['ok'] != true) {
        return Error.errorResponse(data['error'] ?? data['message']);
      }

      return {
        'ok': true,
        'data': data['data'],
        'message': data['message'] ?? 'Successfully fetched repair requests',
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
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'ok': data['ok'] ?? false,
        'recommendations': data['recommendations'] ?? [],
        'message': data['message'] ?? 'Successfully fetched recommendations',
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
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);

      if (data['ok'] == true && data['data'] != null) {
        final modules = data['data']['modules'];
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
          'ok': true,
          'data': mappedModules,
          'message': data['message'] ?? 'Successfully fetched module status',
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
        return Error.errorResponse('Customer ID Required');
      }
      final url = Uri.parse(
        '$restUser/mobile/machine/notifications/$userId/$machineId',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'ok': true,
        'data': data['data'],
        'message': data['message'] ?? 'Successfully fetched all machines',
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
        return Error.errorResponse('Customer ID Required');
      }
      final url = Uri.parse('$restUser/mobile/machine/add-machine');

      final body = {'machineSerial': serialId, 'customerId': userId};
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (data['ok'] != true) {
        return Error.errorResponse(data['error'] ?? data['message']);
      }

      return {
        'ok': true,
        'data': data['data'],
        'message': data['message'] ?? 'Successfully registered user',
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
        return Error.errorResponse('Customer ID Required');
      }
      final url = Uri.parse(
        '$restUser/mobile/machine/delete/$userId/$machineId',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);

      if (data['ok'] != true) {
        return Error.errorResponse(data['error'] ?? data['message']);
      }

      return {
        'ok': true,
        'data': data['data'],
        'message': data['message'] ?? 'Successfully registered user',
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> restartMachine() async {
    try {
      const String espIp = '192.168.1.184';
      final url = Uri.parse('http://$espIp/restart');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return {'ok': true, 'message': 'Restart command sent to ESP32'};
      } else {
        return Error.errorResponse(
          'Machine returned status: ' + response.statusCode.toString(),
        );
      }
    } catch (e) {
      return Error.errorResponse(
        'Connection failed: Ensure you\'re on the same Wi-Fi',
      );
    }
  }

  static Future<Map<String, dynamic>> updateBinNickname({
    required String machineId,
    required String nickname,
  }) async {
    try {
      final userId = await PreferenceUtility.getUserId();
      if (userId == null || userId.isEmpty) {
        return Error.errorResponse('Customer ID Required');
      }
      final url = Uri.parse('$restUser/mobile/bin-settings/nickname');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode({
          'machineId': machineId,
          'customerId': userId,
          'nickname': nickname,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'ok': data['ok'] ?? false,
        'message': data['message'] ?? data['error'] ?? 'Update failed',
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchBinSettings({
    required String machineId,
  }) async {
    try {
      final url = Uri.parse('$restUser/mobile/bin-settings/$machineId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'ok': data['ok'] ?? false,
        'data': data['data'],
        'message': data['message'] ?? 'Successfully fetched bin settings',
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> checkFirmwareUpdate({
    required String machineId,
  }) async {
    try {
      final url = Uri.parse('$restUser/machine/firmware-update/$machineId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateFirmware({
    required String machineId,
    required String version,
  }) async {
    try {
      final url = Uri.parse('$restUser/machine/update-firmware');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode({'machineId': machineId, 'version': version}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }
}
