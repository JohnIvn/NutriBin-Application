import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  colorScheme: ColorScheme.light(
    primary: lightPrimary,
    secondary: lightSecondary,
    tertiary: lightTertiary,
    surface: lightAlternate,
    onPrimary: lightPrimaryText,
    onSecondary: lightPrimaryText,
    onSurface: lightSecondaryText,
  ),
);

// --- Dark ThemeData ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimary,
  scaffoldBackgroundColor: darkPrimaryBackground,
  colorScheme: ColorScheme.dark(
    primary: darkPrimary,
    secondary: darkSecondary,
    tertiary: darkTertiary,
    surface: darkAlternate,
    onPrimary: darkPrimaryText,
    onSecondary: darkPrimaryText,
    onSurface: darkSecondaryText,
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  AuthService().startServer();
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
      initialRoute: '/',
      routes: {
        // Default Route
        '/': (context) => const SignUpPage(),

        // Auth Routes
        '/home': (context) => const HomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfileWidget(),
        '/fertilizers': (context) => const FertilizerPage(),
        '/account': (context) => const AccountPage(),
        '/account-edit': (context) => const AccountEditWidget(),

        // Common Routes
        '/support': (context) => const ContactWidget(),
        '/termsOfService': (context) => const TermsOfServiceWidget(),
        '/about': (context) => const AboutUsPage(),
      },
    );
  }
}
