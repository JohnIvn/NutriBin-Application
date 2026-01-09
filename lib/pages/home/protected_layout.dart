import 'package:flutter/material.dart';

class ProtectedLayout extends StatefulWidget {
  const ProtectedLayout({super.key});

  static String routeName = 'nutribin';
  static String routePath = '/nutribin';

  @override
  State<ProtectedLayout> createState() => _ProtectedLayoutState();
}

class _ProtectedLayoutState extends State<ProtectedLayout> {
  final List<Widget> _pages = const [
    // HomePage(),
    // StatsPage(),
    // AlertsPage(),
    // ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return (Scaffold(appBar: AppBar()));
  }
}
