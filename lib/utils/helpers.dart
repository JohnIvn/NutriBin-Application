import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtility {
  static Future<void> saveSession(
    String userId,
    String email,
    String firstName,
    String lastName,
    String contact,
    String address,
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('contact', contact);
    await prefs.setString('address', address);
    await prefs.setString('token', token);
    await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final timestamp = prefs.getInt('loginTimestamp');
    if (token == null || timestamp == null) return false;

    final expiry = DateTime.fromMillisecondsSinceEpoch(
      timestamp,
    ).add(Duration(hours: 1));
    return DateTime.now().isBefore(expiry);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<int?> getLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('loginTimestamp');
  }

  static Future<Map<String, dynamic>> getProfile({
    bool name = false,
    bool contacts = false,
    bool email = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Object?> profile = {};

    profile["firstName"] = prefs.getString("firstName");
    profile["lastName"] = prefs.getString("lastName");
    profile["contact"] = prefs.getString("contact");
    profile["address"] = prefs.getString("address");
    profile["email"] = prefs.getString("email");

    return profile;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class ValidationUtility {
  static Map<String, dynamic> validatePayload({
    required String email,
    required String firstname,
    required String lastname,
    String? contact,
    required String address,
    required String password,
    required String confirmPassword,
  }) {
    final firstNameValidation = validateName(firstname);
    if (!firstNameValidation["valid"]) {
      return {
        "ok": false,
        "message": "Firstname: ${firstNameValidation["message"]}",
      };
    }

    final lastNameValidation = validateName(lastname);
    if (!lastNameValidation["valid"]) {
      return {
        "ok": false,
        "message": "Lastname: ${lastNameValidation["message"]}",
      };
    }

    final emailValidation = validateEmail(email);
    if (!emailValidation["valid"]) {
      return {"ok": false, "message": emailValidation["message"]};
    }

    if (contact.toString().isNotEmpty) {
      final contactValidation = validateContact(contact.toString());
      if (!contactValidation["valid"]) {
        return {"ok": false, "message": contactValidation["message"]};
      }
    }

    final passwordValidation = validatePassword(password);
    if (!passwordValidation["valid"]) {
      return {"ok": false, "message": passwordValidation["message"]};
    }

    if (password != confirmPassword) {
      return {"ok": false, "message": "Password and Confirm Password mismatch"};
    }

    if (address.trim().isEmpty) {
      return {"ok": false, "message": "Address is required"};
    }

    return {"ok": true, "message": "Valid field inputs"};
  }

  static Map<String, dynamic> validatePassword(String password) {
    if (password.length < 8) {
      return ResponseUtility.invalid("Password must be 8 characters or more");
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ResponseUtility.invalid(
        "Password must contain capital characters",
      );
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return ResponseUtility.invalid("Password must contain small characters");
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return ResponseUtility.invalid(
        "Password must contain numeric characters",
      );
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return ResponseUtility.invalid(
        "Password must contain special characters",
      );
    }

    return {"ok": true, "message": "Valid password"};
  }

  static Map<String, dynamic> validateName(String value) {
    final name = value.trim();
    if (name.length < 2) {
      return ResponseUtility.invalid("Name must be greater than 2 characters");
    }

    final RegExp nameRegex = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');
    if (!nameRegex.hasMatch(name)) {
      return ResponseUtility.invalid(
        "Name must only contain alphabetical characters",
      );
    }
    return {"ok": true, "message": "Valid name"};
  }

  static Map<String, dynamic> validateContact(String value) {
    final RegExp phContactRegex = RegExp(r'^(09\d{9}|\+639\d{9})$');
    if (!phContactRegex.hasMatch(value.trim())) {
      return ResponseUtility.invalid("Please use PH format numbers (+63)");
    }

    return {"ok": true, "message": "Valid contacts"};
  }

  static Map<String, dynamic> validateEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return ResponseUtility.invalid("Empty email");
    }

    final parts = email.split('@');

    if (parts.length != 2) {
      return ResponseUtility.invalid("Invalid email format");
    }

    final localPart = parts[0].trim();
    final domainPart = parts[1].trim().toLowerCase();

    final RegExp localRegex = RegExp(r'^[a-zA-Z0-9._%+-]+$');

    if (!localRegex.hasMatch(localPart)) {
      return ResponseUtility.invalid("Invalid email name");
    }

    final RegExp domainRegex = RegExp(r'^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$');

    if (!domainRegex.hasMatch(domainPart)) {
      return ResponseUtility.invalid("Invalid email domain");
    }

    return {"ok": true, "message": "Valid email"};
  }
}

class ResponseUtility {
  static Map<String, dynamic> invalid(String message) {
    return {"ok": false, "message": message};
  }
}
