import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleOAuthService {
  // Private instance
  static GoogleSignIn? _googleSignIn;

  /// Initialize Google OAuth
  static void initialize() {
    final clientId = dotenv.env['GOOGLE_CLIENT_ID'];

    if (clientId == null || clientId.isEmpty) {
      throw Exception(
        "GOOGLE_CLIENT_ID not found in .env. Make sure to load dotenv first.",
      );
    }

    _googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: ['email', 'profile'],
    );
  }

  /// Ensure service is initialized
  static GoogleSignIn get _instance {
    if (_googleSignIn == null) {
      throw Exception(
        "GoogleOAuthService not initialized. Call initialize() first.",
      );
    }
    return _googleSignIn!;
  }

  /// Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _instance.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in cancelled'};
      }

      final googleAuth = await googleUser.authentication;

      final result = await _authenticateWithBackend(
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      return result;
    } catch (e) {
      print('Error signing in with Google: $e');
      return {
        'success': false,
        'message': 'Failed to sign in with Google: ${e.toString()}',
      };
    }
  }

  /// Authenticate with backend
  static Future<Map<String, dynamic>> _authenticateWithBackend({
    required String? email,
    required String? displayName,
    required String? photoUrl,
    required String? idToken,
    required String? accessToken,
  }) async {
    try {
      final baseUrl = dotenv.env['SUPABASE_URL'] ?? 'http://localhost:3000';
      // final url = Uri.parse('$baseUrl/api/auth/google');
      final url = Uri.parse('$baseUrl/functions/v1/googleAuth');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'displayName': displayName,
          'photoUrl': photoUrl,
          'idToken': idToken,
          'accessToken': accessToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'isNewUser': data['isNewUser'] ?? false,
          'requiresEmailVerification':
              data['requiresEmailVerification'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Authentication failed',
        };
      }
    } catch (e) {
      print('Backend authentication error: $e');
      return {
        'success': false,
        'message': 'Failed to authenticate with server: ${e.toString()}',
      };
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _instance.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  /// Check if signed in
  static Future<bool> isSignedIn() async {
    return await _instance.isSignedIn();
  }

  /// Get current user
  static GoogleSignInAccount? getCurrentUser() {
    return _instance.currentUser;
  }

  /// Silent sign in
  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _instance.signInSilently();
    } catch (e) {
      print('Silent sign in failed: $e');
      return null;
    }
  }
}
