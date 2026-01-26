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

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firstName');
  }

  static Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastName');
  }

  static Future<String?> getContact() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('contact');
  }

  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('address');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<int?> getLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('loginTimestamp');
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

  /// Clear all session data (for logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Clear only auth-related data (keeps app preferences)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('contact');
    await prefs.remove('address');
    await prefs.remove('loginTimestamp');
    // await prefs.remove('authToken'); // Uncomment when token is implemented
  }

  /// Update user profile data
  static Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? contact,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (firstName != null) {
      await prefs.setString('firstName', firstName);
    }
    if (lastName != null) {
      await prefs.setString('lastName', lastName);
    }
    if (contact != null) {
      await prefs.setString('contact', contact);
    }
    if (address != null) {
      await prefs.setString('address', address);
    }
  }

  /// Get full user data as a map
  static Future<Map<String, String?>> getFullUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId'),
      'email': prefs.getString('email'),
      'firstName': prefs.getString('firstName'),
      'lastName': prefs.getString('lastName'),
      'contact': prefs.getString('contact'),
      'address': prefs.getString('address'),
    };
  }
}

class AuthUtility {}
