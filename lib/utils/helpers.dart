import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtility {
  static Future<void> saveSession(
    String userId,
    String email,
    String firstName,
    String lastName,
    String contact,
    String address,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('contact', contact);
    await prefs.setString('address', address);
    await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);

    // Temporary Comment Out, backend connection doesnt exist yet
    // if (userData['token'] != null) {
    //   await prefs.setString('authToken', userData['token'].toString());
    // }
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  static Future<Map<String, Object?>> getProfile({
    bool name = false,
    bool contacts = false,
    bool email = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Object?> profile = {};

    if (name) {
      profile["firstName"] = prefs.getString("firstName");
      profile["lastName"] = prefs.getString("lastName");
    }

    if (contacts) {
      profile["contact"] = prefs.getString("contact");
      profile["address"] = prefs.getString("address");
    }

    if (email) {
      profile["email"] = prefs.getString("email");
    }

    return profile;
  }
}


class AuthUtility {}
