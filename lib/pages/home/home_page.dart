import 'package:flutter/material.dart';
import 'package:nutribin_application/models/machine.dart';
import 'package:nutribin_application/pages/home/account.dart';
import 'package:nutribin_application/pages/home/dashboard.dart';
import 'package:nutribin_application/pages/home/fertilizer.dart';
import 'package:nutribin_application/pages/home/notification_page.dart';
import 'package:nutribin_application/pages/home/nutribin_page.dart';
import 'package:nutribin_application/widgets/custom_appbar.dart';
import 'package:nutribin_application/widgets/custom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _machineName;
  String? _machineId;

  List<Widget> get _pages => [
    DashboardPage(machineId: _machineId ?? ''),
    FertilizerPage(machineId: _machineId ?? ''),
    NutriBinPage(machineId: _machineId ?? ''),
    const NotificationPage(),
    const AccountPage(),
  ];

  void initState() {
    super.initState();
    _checkSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        setState(() {
          _machineName = arguments["serialNumber"];
          _machineId = arguments["machineId"].toString();
        });
      }
    });
  }

  Future<void> _checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to continue'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        }
      } else {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });

        _checkSessionExpiry(prefs);
      }
    } catch (e) {
      print('Session check error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session error. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  Future<void> _checkSessionExpiry(SharedPreferences prefs) async {
    final loginTimestamp = prefs.getInt('loginTimestamp');

    if (loginTimestamp != null) {
      final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(loginTime);

      if (difference.inDays > 7) {
        await prefs.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your session has expired. Please log in again.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: CustomAppBar(machineNameOverride: _machineName),
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
