import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDark
        ? const Color(0xFFB5C1B8)
        : const Color(0xFF57636C);
    final borderColor = isDark
        ? const Color(0xFF2F3532)
        : const Color(0xFFE0E3E7);
    final labelColor = isDark ? Colors.white : const Color(0xFF101213);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            children: [
              Expanded(child: Divider(color: dividerColor, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Expanded(child: Divider(color: dividerColor, thickness: 1)),
            ],
          ),
        ),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(230, 52),
              side: BorderSide(color: borderColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            icon: Image.asset(
              'assets/images/google.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              'Continue with Google',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
