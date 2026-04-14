import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutribin_application/utils/response_handler.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:http/http.dart' as http;

final String restUser = dotenv.env['RAILWAY_USER'].toString();
final String anonKey = dotenv.env['SUPABASE_ANON'].toString();

class EmergencyService {
  static Future<Map<String, dynamic>> triggerEmergency({
    required String machineId,
  }) async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse('Customer ID Required');
      }

      final url = Uri.parse('$restUser/settings/emergency');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode({'customerId': userId, 'machine_id': machineId}),
      );

      final data = jsonDecode(response.body);
      return {
        'ok': data['ok'] ?? false,
        'message': data['message'] ?? 'Emergency triggered',
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> checkEmergencyStatus({
    required String machineId,
  }) async {
    try {
      final userId = await PreferenceUtility.getUserId();

      if (userId == null || userId.isEmpty) {
        return Error.errorResponse('Customer ID Required');
      }

      // Query the emergency status for this machine
      // This would be a new endpoint or we can fetch from the machines endpoint
      // For now, we'll assume the machines list includes emergency status
      final url = Uri.parse('$restUser/mobile/machine/$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      final data = jsonDecode(response.body);

      // Find the machine and check if it has emergency active
      if (data['data'] is List) {
        final machines = data['data'] as List;
        for (var machine in machines) {
          if (machine['machine_id'] == machineId) {
            return {
              'ok': true,
              'is_active': machine['is_emergency'] ?? false,
              'machine': machine,
            };
          }
        }
      }

      return {'ok': false, 'is_active': false, 'message': 'Machine not found'};
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }
}
