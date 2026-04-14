import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/services/emergency_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? machineNameOverride;
  final bool? isOnline;
  final bool isEmergency;
  final String machineId;
  final VoidCallback? onEmergencyPressed;

  const CustomAppBar({
    super.key,
    this.showBackButton = true,
    this.machineNameOverride,
    this.isOnline,
    this.isEmergency = false,
    this.machineId = '',
    this.onEmergencyPressed,
  });

  Future<void> _triggerEmergency(BuildContext context) async {
    if (machineId.isEmpty) return;

    final result = await EmergencyService.triggerEmergency(
      machineId: machineId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Emergency triggered'),
          backgroundColor: result['ok'] == true ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (onEmergencyPressed != null) {
      onEmergencyPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- COLOR LOGIC ---
    // Light Mode: Green Background normally, Red if Emergency
    // Dark Mode: Dark Background normally, Red if Emergency
    final appBarBg = isEmergency
        ? Colors.red
        : (isDarkMode ? backgroundColor : primaryColor);
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
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return _EmergencyCountdownDialog(
                        machineId: machineId,
                        onEmergencyTriggered: () => _triggerEmergency(context),
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

class _EmergencyCountdownDialog extends StatefulWidget {
  final String machineId;
  final VoidCallback onEmergencyTriggered;

  const _EmergencyCountdownDialog({
    required this.machineId,
    required this.onEmergencyTriggered,
  });

  @override
  State<_EmergencyCountdownDialog> createState() =>
      _EmergencyCountdownDialogState();
}

class _EmergencyCountdownDialogState extends State<_EmergencyCountdownDialog> {
  late int countdown;
  Timer? countdownTimer;
  bool isCancelled = false;

  @override
  void initState() {
    super.initState();
    countdown = 5;
    startCountdown();
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isCancelled) {
        timer.cancel();
        return;
      }

      setState(() {
        countdown--;
      });

      if (countdown < 0) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
          widget.onEmergencyTriggered();
        }
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        isCancelled = true;
        countdownTimer?.cancel();
        return true;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_rounded, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Emergency Alert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Emergency will be triggered in',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 3),
              ),
              child: Center(
                child: Text(
                  '$countdown',
                  style: GoogleFonts.interTight(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Click Cancel to stop',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                isCancelled = true;
                countdownTimer?.cancel();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: isDark ? Colors.white : Colors.blueGrey,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
