import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtility {
  static Future<void> saveSession(
    String userId,
    String email,
    String firstName,
    String lastName,
    String gender,
    String contact,
    String address,
    String birthday,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    int age = ProfileUtility.calculateAge(birthday);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('gender', gender);
    await prefs.setString('contact', contact);
    await prefs.setString('address', address);
    await prefs.setString('birthday', birthday);
    await prefs.setString('age', age.toString());
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
    bool birthday = false,
    bool email = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Object?> profile = {};

    if (name) {
      profile["firstName"] = prefs.getString("firstName");
      profile["lastName"] = prefs.getString("lastName");
      profile["gender"] = prefs.getString("gender");
    }

    if (contacts) {
      profile["contact"] = prefs.getString("contact");
      profile["address"] = prefs.getString("address");
    }

    if (birthday) {
      profile["birthday"] = prefs.getString("birthday");
      profile["age"] = ProfileUtility.calculateAge(
        profile["birthday"].toString(),
      );
    }

    if (email) {
      profile["email"] = prefs.getString("email");
    }

    return profile;
  }
}

class ProfileUtility {
  static int calculateAge(String birthday) {
    if (birthday.isEmpty) return 0;
    try {
      // Make sure the birthday string is in 'yyyy-MM-dd' format
      final birthDate = DateTime.parse(birthday);
      final today = DateTime.now();
      int age = today.year - birthDate.year;

      // If birthday hasn't happened yet this year, subtract 1
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      print('Error calculating age: $e');
      return 0;
    }
  }
}

class AuthUtility {}
