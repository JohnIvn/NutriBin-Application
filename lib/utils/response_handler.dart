class ResponseUtility {


  static Map<String, dynamic> invalid(String message) {
    return {"ok": false, "message": message};
  }
}

class Error {
}

class Success {
  static Map<String, dynamic> successResponse() {

    return {"ok": true, "message": "Valid contacts"};
  }
}