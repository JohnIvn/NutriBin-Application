import 'package:flutter/material.dart';
import 'package:nutribin_application/pages/home/account.dart';
import 'package:nutribin_application/pages/home/dashboard.dart';
import 'package:nutribin_application/pages/home/fertilizer.dart';
import 'package:nutribin_application/pages/home/notification_page.dart';
import 'package:nutribin_application/pages/home/nutribin_page.dart';
import 'package:nutribin_application/widgets/custom_appbar.dart';
import 'package:nutribin_application/widgets/custom_navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    FertilizerPage(),
    NutriBinPage(),
    NotificationPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
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
