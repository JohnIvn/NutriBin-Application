import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutribin_application/pages/auth/forgot_password.dart';
import 'package:nutribin_application/pages/auth/otp_contacts.dart';
import 'package:nutribin_application/pages/auth/reset_password.dart';
import 'package:nutribin_application/pages/home/machine_page.dart';
import 'package:nutribin_application/pages/home/mfa_settings.dart';
import 'package:nutribin_application/services/auth_service.dart';
import 'package:nutribin_application/pages/common/about.dart';
import 'package:nutribin_application/pages/home/account.dart';
import 'package:nutribin_application/pages/home/account_edit.dart';
import 'package:nutribin_application/pages/home/dashboard.dart';
import 'package:nutribin_application/pages/home/fertilizer.dart';
import 'package:nutribin_application/pages/home/profile.dart';
import 'package:nutribin_application/pages/auth/signup.dart';
import 'package:nutribin_application/pages/home/home_page.dart';
import 'package:nutribin_application/pages/common/support.dart';
import 'package:nutribin_application/pages/common/terms.dart';
import 'package:nutribin_application/services/google_auth_service.dart';
import 'package:nutribin_application/widgets/map_picker.dart';
import 'package:nutribin_application/widgets/terms_accept.dart';

// LIGHT THEME
final Color lightPrimary = Color(0xFF3A4D39);
final Color lightSecondary = Color(0xFF4F6F52);
final Color lightTertiary = Color(0xFF739072);
final Color lightAlternate = Color(0xFFECE3CE);
final Color lightPrimaryText = Color(0xFF1F2326);
final Color lightSecondaryText = Color(0xFF4F6F52);
final Color lightPrimaryBackground = Color(0xFFF1F4F8);
final Color lightSecondaryBackground = Color(0xFFFFFFFF);
final Color lightBorder = Color(0xFFD6D9DC);
final Color lightSuccess = Color(0xFF739072);
final Color lightWarning = Color(0xFFE0B15C);
final Color lightError = Color(0xFFB84A4A);

// DARK THEME
final Color darkPrimary = Color(0xFF2C3A30);
final Color darkSecondary = Color(0xFF4F6F52);
final Color darkTertiary = Color(0xFF8FAE8F);
final Color darkAlternate = Color(0xFF3A403C);
final Color darkPrimaryText = Color(0xFFFFFFFF);
final Color darkSecondaryText = Color(0xFFB5C1B8);
final Color darkPrimaryBackground = Color(0xFF141A17);
final Color darkSecondaryBackground = Color(0xFF1C2420);
final Color darkBorder = Color(0xFF2F3532);
final Color darkSuccess = Color(0xFF8FAE8F);
final Color darkWarning = Color(0xFFD4A24C);
final Color darkError = Color(0xFFD16A6A);

// --- Light ThemeData ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: lightPrimary,
  scaffoldBackgroundColor: lightPrimaryBackground,
  cardTheme: CardThemeData(
    color: lightSecondaryBackground,
    elevation: 0,
    margin: EdgeInsets.zero,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: lightPrimaryBackground,
    foregroundColor: lightPrimaryText,
    elevation: 0,
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: lightPrimaryText),
    bodySmall: TextStyle(color: lightSecondaryText),
    titleLarge: TextStyle(color: lightPrimaryText),
  ),
  colorScheme: ColorScheme.light(
    primary: lightPrimary,
    secondary: lightSecondary,
    tertiary: lightTertiary,
    surface: lightSecondaryBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: lightPrimaryText,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: lightSecondaryBackground, // White
    selectedItemColor: lightPrimary, // Green
    unselectedItemColor: lightSecondaryText, // Greyish Green
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);

// --- Dark ThemeData ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimary,
  scaffoldBackgroundColor: darkPrimaryBackground,
  cardTheme: CardThemeData(
    color: darkSecondaryBackground,
    elevation: 0,
    margin: EdgeInsets.zero,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkPrimaryBackground,
    foregroundColor: darkPrimaryText,
    elevation: 0,
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: darkPrimaryText),
    bodySmall: TextStyle(color: darkSecondaryText),
    titleLarge: TextStyle(color: darkPrimaryText),
  ),
  colorScheme: ColorScheme.dark(
    primary: darkPrimary,
    secondary: darkSecondary,
    tertiary: darkTertiary,
    surface: darkSecondaryBackground,
    onPrimary: darkPrimaryText,
    onSecondary: darkPrimaryText,
    onSurface: darkPrimaryText,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkSecondaryBackground, // Dark Grey
    selectedItemColor: darkTertiary, // Lighter Green for visibility on dark
    unselectedItemColor: darkSecondaryText, // Light Grey
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  GoogleOAuthService.initialize();
  AuthUtility().startServer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // Default Route
        '/': (context) => const SignUpPage(),

        // Auth Routes
        '/machines': (context) => const MachinesHomePage(),
        '/home': (context) => const HomePage(),
        // '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfileWidget(),
        // '/fertilizers': (context) => const FertilizerPage(),
        '/account': (context) => const AccountPage(),
        '/account-edit': (context) => const AccountEditWidget(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/map-picker': (context) => const MapPickerPage(),
        '/verify-contacts': (context) => const ContactsVerification(),
        '/terms-acceptance': (context) => const TermsAcceptancePage(),
        '/mfa-settings': (context) => const MfaSettingsPage(),

        // Common Routes
        '/support': (context) => const ContactWidget(),
        '/termsOfService': (context) => const TermsOfServiceWidget(),
        '/about': (context) => const AboutUsPage(),
      },
    );
  }
}
