import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutribin_application/services/auth_service.dart';

class GoogleOAuthService {
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

  /// Sign in with Google (tries sign-in first, then sign-up if needed)
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _instance.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in cancelled by user'};
      }

      final googleAuth = await googleUser.authentication;

      // Validate tokens
      if (googleAuth.idToken == null) {
        return {
          'success': false,
          'message': 'Failed to get authentication token',
        };
      }

      // Try to sign in first
      final signInResult = await AuthService.googleSignIn(
        idToken: googleAuth.idToken!,
      );

      if (signInResult['ok'] == true) {
        return {
          'success': true,
          'user': signInResult['user'],
          'isNewUser': false,
        };
      }

      // If sign-in failed because account doesn't exist, try sign-up
      if (signInResult['message']?.contains('No account found') == true) {
        final signUpResult = await AuthService.googleSignUp(
          idToken: googleAuth.idToken!,
        );

        if (signUpResult['ok'] == true) {
          return {
            'success': true,
            'user': signUpResult['user'],
            'isNewUser': true,
          };
        }

        return {
          'success': false,
          'message': signUpResult['message'] ?? 'Failed to create account',
        };
      }

      // Other sign-in error
      return {
        'success': false,
        'message': signInResult['message'] ?? 'Authentication failed',
      };
    } catch (e) {
      print('Error signing in with Google: $e');
      return {
        'success': false,
        'message': 'Failed to sign in with Google: ${e.toString()}',
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
