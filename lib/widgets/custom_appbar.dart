import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? machineNameOverride;
  final bool? isOnline;
  final VoidCallback? onEmergencyPressed;

  const CustomAppBar({
    super.key,
    this.showBackButton = true,
    this.machineNameOverride,
    this.isOnline,
    this.onEmergencyPressed,
  });

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- COLOR LOGIC ---
    // Light Mode: Green Background
    // Dark Mode: Dark Background
    final appBarBg = isDarkMode ? backgroundColor : primaryColor;
    const contentColor = Colors.white;

    return AppBar(
      backgroundColor: appBarBg,
      automaticallyImplyLeading: false,
      elevation: 2,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight,

      // Status Bar
      systemOverlayStyle: SystemUiOverlayStyle.light,

      // Bottom Border with subtle shadow
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back Button Logic
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: contentColor),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Back',
              splashRadius: 24,
            )
          else
            const SizedBox(width: 8),

          const SizedBox(width: 12),

          // Display machine name
          if (machineNameOverride != null && machineNameOverride!.isNotEmpty)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      machineNameOverride!,
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: contentColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOnline != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline!
                            ? Colors.greenAccent
                            : Colors.grey[400],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isOnline! ? Colors.green : Colors.grey[500]!,
                          width: 1,
                        ),
                        boxShadow: isOnline!
                            ? [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1.5,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset('assets/images/Logo (Img).png', height: 40),

                  const SizedBox(width: 14),

                  // App name
                  Text(
                    'NutriBin',
                    style: GoogleFonts.interTight(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: contentColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      centerTitle: false,
      titleSpacing: 16,

      // Emergency Button
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.emergency, color: Colors.red),
                iconSize: 18,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Emergency Alert'),
                          ],
                        ),
                        content: const Text(
                          'Are you sure you want to trigger an emergency alert?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.blueGrey,
                            ),
                            child: const Text('Dismiss'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onEmergencyPressed != null) {
                                onEmergencyPressed!();
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Emergency Alert',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
