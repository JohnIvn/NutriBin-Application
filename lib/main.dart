import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutribin_application/pages/common/about.dart';
import 'package:nutribin_application/pages/home/account.dart';
import 'package:nutribin_application/pages/home/account_edit.dart';
import 'package:nutribin_application/pages/camera.dart';
import 'package:nutribin_application/pages/home/dashboard.dart';
import 'package:nutribin_application/pages/home/fertilizer.dart';
import 'package:nutribin_application/pages/machine.dart';
import 'package:nutribin_application/pages/home/profile.dart';
import 'package:nutribin_application/pages/auth/signup.dart';
import 'package:nutribin_application/pages/home/home_page.dart';
import 'package:nutribin_application/pages/common/support.dart';
import 'package:nutribin_application/pages/common/terms.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- Light theme colors ---
final Color lightPrimary = Color(0xfff17720);
final Color lightSecondary = Color(0xFF0474BA);
final Color lightTertiary = Color(0xFF4B39EF);
final Color lightAlternate = Color(0xFFE0E3E7);
final Color lightPrimaryText = Color(0xFFFFFFFF);
final Color lightSecondaryText = Color(0xFF1F2326);
final Color lightPrimaryBackground = Color(0xFFF1F4F8);
final Color lightSecondaryBackground = Color(0xFFFFFFFF);

// --- Dark theme colors ---
final Color darkPrimary = Color(0xFF000000);
final Color darkSecondary = Color(0xFF39D2C0);
final Color darkTertiary = Color(0xFFEE8B60);
final Color darkAlternate = Color(0xFFE5E5E5);
final Color darkPrimaryText = Color(0xFFFFFFFF);
final Color darkSecondaryText = Color(0xFF95A1AC);
final Color darkPrimaryBackground = Color(0xFF1D2428);
final Color darkSecondaryBackground = Color(0xFF14181B);

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
  // textTheme: TextTheme(
  //   bodyText1: TextStyle(color: lightSecondaryText),
  //   bodyText2: TextStyle(color: lightSecondaryText),
  // ),
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
  // textTheme: TextTheme(

  //   bodyText1: TextStyle(color: darkSecondaryText),
  //   bodyText2: TextStyle(color: darkSecondaryText),
  // ),
);

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme, // <-- use the Light theme
      darkTheme: darkTheme, // <-- use the Dark theme
      themeMode: ThemeMode.system, // <-- switch automatically
      initialRoute: '/',
      routes: {
        // '/': (context) => const LandingPage(),
        '/': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/account': (context) => const AccountPage(),
        '/account-edit': (context) => const AccountEditWidget(),
        '/support': (context) => const ContactWidget(),
        '/termsOfService': (context) => const TermsOfServiceWidget(),
        '/profile': (context) => const ProfileWidget(),
        '/machine': (context) => const MachineWidget(),
        '/camera': (context) => const CameraWidget(),
        '/about': (context) => const AboutUsPage(),
        '/fertilizers': (context) => const FertilizerPage(),
        // '/account/edit': (context) => const AccountEditPage(),
      },
    );
  }
}
