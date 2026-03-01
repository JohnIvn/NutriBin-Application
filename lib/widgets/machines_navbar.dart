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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final navBarBg = isDarkMode
        ? Theme.of(context).cardTheme.color ?? Colors.grey[800]!
        : Theme.of(context).primaryColor;

    // Each step highlights one nav item, but shows the full navbar replica
    // as the tooltip content so nothing feels out of place.
    return [
      TargetFocus(
        identify: "home_key",
        keyTarget: _navKeys[0],
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _NavBarTutorialOverlay(
                navBarBg: navBarBg,
                highlightIndex: 0,
                title: "Home",
                description:
                    "View and manage all your registered NutriBin machines.",
                isLast: false,
                onNext: controller.next,
                onSkip: () {
                  _saveTutorialCompleted();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "guide_key",
        keyTarget: _navKeys[1],
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _NavBarTutorialOverlay(
                navBarBg: navBarBg,
                highlightIndex: 1,
                title: "Guide",
                description:
                    "Access comprehensive guides, tips, and tutorials.",
                isLast: false,
                onNext: controller.next,
                onSkip: () {
                  _saveTutorialCompleted();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "account_key",
        keyTarget: _navKeys[2],
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _NavBarTutorialOverlay(
                navBarBg: navBarBg,
                highlightIndex: 2,
                title: "Settings",
                description:
                    "Manage your profile, app settings, and account preferences.",
                isLast: true,
                onNext: controller.next, // triggers onFinish
                onSkip: () {
                  _saveTutorialCompleted();
                  controller.skip();
                },
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

    const borderColor = Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: navBarBg,
        border: const Border(top: BorderSide(color: borderColor, width: 1.0)),
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, key: _navKeys[0]),
              activeIcon: const Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined, key: _navKeys[1]),
              activeIcon: const Icon(Icons.menu_book),
              label: 'Guide',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, key: _navKeys[2]),
              activeIcon: const Icon(Icons.person),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tutorial overlay that mirrors the exact navbar layout
// ---------------------------------------------------------------------------

class _NavBarTutorialOverlay extends StatelessWidget {
  final Color navBarBg;
  final int highlightIndex;
  final String title;
  final String description;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _NavBarTutorialOverlay({
    required this.navBarBg,
    required this.highlightIndex,
    required this.title,
    required this.description,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    (
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      label: 'Guide',
    ),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Description card ──────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: navBarBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onNext,
                    icon: Icon(
                      isLast ? Icons.check : Icons.arrow_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      isLast ? 'Done' : 'Next',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Navbar replica ────────────────────────────────────────────────
        Container(
          color: navBarBg,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isHighlighted = i == highlightIndex;
              final iconColor = isHighlighted ? Colors.white : Colors.white38;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isHighlighted ? item.activeIcon : item.icon,
                        color: iconColor,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: iconColor,
                          fontWeight: isHighlighted
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
