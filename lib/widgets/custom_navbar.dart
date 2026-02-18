import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  final List<GlobalKey> _navKeys = List.generate(4, (_) => GlobalKey());
  TutorialCoachMark? _tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('navbar_tutorial_seen') ?? false;

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
        await prefs.setBool('navbar_tutorial_seen', true);
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
    await prefs.setBool('navbar_tutorial_seen', true);
  }

  void showTutorialManually() {
    _showTutorial();
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "fertilizers_key",
        keyTarget: _navKeys[1],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fertilizers",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Browse and manage your fertilizer inventory",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "nutribin_key",
        keyTarget: _navKeys[2],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NutriBin",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Track your composting and waste management",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "notifications_key",
        keyTarget: _navKeys[3],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Stay updated with important alerts and reminders",
                      style: TextStyle(fontSize: 14, color: Colors.white),
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

    final navBarBg = isDarkMode
        ? Theme.of(context).cardTheme.color
        : Theme.of(context).primaryColor;

    const selectedItemColor = Colors.white;
    final unselectedItemColor = isDarkMode ? Colors.grey : Colors.white60;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.transparent, width: 1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: navBarBg,
          elevation: 0,

          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,

          items: [
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.home_outlined, key: _navKeys[0]),
            //   label: 'Home',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture_outlined, key: _navKeys[1]),
              label: 'Fertilizers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restore_from_trash_outlined, key: _navKeys[2]),
              label: 'NutriBin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined, key: _navKeys[3]),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}
