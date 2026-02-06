import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleOAuthService {
  static GoogleSignIn? _googleSignIn;

  static void initialize() {
    final clientId = dotenv.env['ANDROID_GOOGLE_CLIENT_ID'].toString();

    if (clientId.isEmpty) {
      throw Exception(
        "GOOGLE_CLIENT_ID not found in .env. Make sure to load dotenv first.",
      );
    }

    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: dotenv.env['ANDROID_GOOGLE_CLIENT_ID'].toString(),
    );
  }

  static GoogleSignIn get _instance {
    if (_googleSignIn == null) {
      throw Exception(
        "GoogleOAuthService not initialized. Call initialize() first.",
      );
    }
    return _googleSignIn!;
  }

  static Future<void> signOut() async {
    try {
      await _instance.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  static Future<bool> isSignedIn() async {
    return await _instance.isSignedIn();
  }

  static GoogleSignInAccount? getCurrentUser() {
    return _instance.currentUser;
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _instance.signInSilently();
    } catch (e) {
      return null;
    }
  }
}
