import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MachinesNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MachinesNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MachinesNavBar> createState() => _MachinesNavBarState();
}

class _MachinesNavBarState extends State<MachinesNavBar> {
  final List<GlobalKey> _navKeys = List.generate(3, (_) => GlobalKey());
  TutorialCoachMark? _tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial =
        prefs.getBool('machines_navbar_tutorial_seen') ?? false;

    if (!hasSeenTutorial && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorial();
      });
    }
  }

  void _showTutorial() {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('machines_navbar_tutorial_seen', true);
      },
      onSkip: () {
        _saveTutorialCompleted();
        return true;
      },
    );
    _tutorialCoachMark?.show(context: context);
  }

  Future<void> _saveTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('machines_navbar_tutorial_seen', true);
  }

  void showTutorialManually() {
    _showTutorial();
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "home_key",
        keyTarget: _navKeys[0],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Home",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "View and manage all your registered NutriBin machines.",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      onPressed: () {
                        controller.next();
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Next',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "guide_key",
        keyTarget: _navKeys[1],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Guide",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Access comprehensive guides, tips, and tutorials.",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "account_key",
        keyTarget: _navKeys[2],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Manage your profile, app settings, and account preferences.",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _tutorialCoachMark?.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- navbar colors---
    final navBarBg = isDarkMode
        ? Theme.of(context).cardTheme.color
        : Theme.of(context).primaryColor;

    // Icons - matching custom_appbar.dart contentColor
    const selectedItemColor = Colors.white;
    final unselectedItemColor = isDarkMode ? Colors.grey : Colors.white60;

    const borderColor = Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: navBarBg,
        border: const Border(top: BorderSide(color: borderColor, width: 1.0)),
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,

        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, key: _navKeys[0]),
            activeIcon: Icon(Icons.home, key: ValueKey('home_active')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined, key: _navKeys[1]),
            activeIcon: Icon(Icons.menu_book),
            label: 'Guide',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, key: _navKeys[2]),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
