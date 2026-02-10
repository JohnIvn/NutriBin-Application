import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? machineNameOverride;

  const CustomAppBar({
    super.key,
    this.showBackButton = true,
    this.machineNameOverride,
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
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight,

      // Status Bar
      systemOverlayStyle: SystemUiOverlayStyle.light,

      // Bottom Border
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.transparent, height: 1.0),
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
            )
          else
            const SizedBox(width: 8),

          const SizedBox(width: 12),

          // Display machine name
          if (machineNameOverride != null && machineNameOverride!.isNotEmpty)
            Text(
              machineNameOverride!,
              style: GoogleFonts.interTight(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: contentColor,
              ),
            )
          else
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset('assets/images/Logo (Img).png', height: 40),

                  const SizedBox(width: 12),

                  // App name
                  Text(
                    'NutriBin',
                    style: GoogleFonts.interTight(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: contentColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      centerTitle: false,
      titleSpacing: 16,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
