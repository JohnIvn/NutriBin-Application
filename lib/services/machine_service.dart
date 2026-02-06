import 'package:nutribin_application/utils/response_handler.dart';

class MachineService {
  static Future<Map<String, dynamic>> fetchExistingMachines({
    required String customerId,
  }) async {
    try {
      if (customerId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      return {
        "ok": true,
        "data": "data", //Temporary
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchFertilizerStatus({
    required String customerId,
  }) async {
    try {
      if (customerId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      return {
        "ok": true,
        "data": "data", //Temporary
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchMachineStatus({
    required String customerId,
    required String machineId,
  }) async {
    try {
      if (customerId.isEmpty) {
        return Error.errorResponse("Customer ID Required");
      }
      if (machineId.isEmpty) {
        return Error.errorResponse("Machine ID Required");
      }
      return {
        "ok": true,
        "data": "data", //Temporary
      };
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }
}
