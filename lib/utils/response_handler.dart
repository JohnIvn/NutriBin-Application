import 'dart:convert';
import 'package:http/http.dart';

class ResponseUtility {
  static Map<String, dynamic> validateResponse(Response response) {
    final result = jsonDecode(response.body);
    String message = result["message"] ?? result["error"];

    if (result["ok"] != true) {
      return Error.errorResponse(message);
    }
    return Success.successResponse(message, result["data"]);
  }
}

class Error {
  static Map<String, dynamic> errorResponse(String? message) {
    return {"ok": false, "message": message.toString()};
  }
}

class Success {
  static Map<String, dynamic> successResponse(
    String? message,
    Map<String, dynamic> data,
  ) {
    return {"ok": true, "message": message.toString(), "data": data};
  }
}
