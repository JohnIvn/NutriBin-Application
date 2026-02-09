import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceWidget extends StatefulWidget {
  const TermsOfServiceWidget({super.key});

  static String routeName = 'TermsOfService';
  static String routePath = '/termsOfService';

  @override
  State<TermsOfServiceWidget> createState() => _TermsOfServiceWidgetState();
}

class _TermsOfServiceWidgetState extends State<TermsOfServiceWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _listFadeAnimation;
  late Animation<Offset> _listSlideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeInOut),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(
          begin: const Offset(
            0.0,
            30.0,
          ),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.1, 0.7, curve: Curves.easeInOut),
          ),
        );

    // List animation
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.75, curve: Curves.easeInOut),
      ),
    );

    _listSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 30.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.15, 0.75, curve: Curves.easeInOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final dividerColor = Theme.of(context).dividerColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- APP BAR CONFIG ---
    final appBarBg = isDarkMode ? backgroundColor : primaryColor;
    const appBarContentColor = Colors.white;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: appBarBg,
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 60,
          systemOverlayStyle: SystemUiOverlayStyle.light,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 24),
            color: appBarContentColor,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Terms of Service',
            style: GoogleFonts.interTight(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: appBarContentColor,
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.transparent, height: 1.0),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Logo & Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/Logo (Img).png',
                        width: 40,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NutriBin',
                            style: GoogleFonts.interTight(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? Colors.white
                                  : primaryColor, // White in dark mode
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Excess Food Composting System',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Divider(height: 1, thickness: 1, color: dividerColor),

                const SizedBox(height: 24),

                // Last Updated
                Text(
                  'Last Updated: January 2026',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : primaryColor,
                  ),
                ),

                const SizedBox(height: 16),

                // Introduction Text
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _textSlideAnimation.value,
                      child: Opacity(
                        opacity: _textFadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'By accessing or using the NutriBin web application, hardware system, or any related services (collectively referred to as the "System"), you agree to be bound by these Terms of Service. If you do not agree to these terms, you must not use the System.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textColor, // Dynamic text color
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Terms List
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _listSlideAnimation.value,
                      child: Opacity(
                        opacity: _listFadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _buildTermCard(
                        title: '1. Purpose of the System',
                        content:
                            'NutriBin is designed to monitor and manage the composting of soft or small biodegradable waste for fertilizer production. The System provides real-time sensor data, status monitoring, logging, and alerts related to compost quality and safety.\n\nNutriBin is intended for educational, research, and prototype demonstration purposes and is not a certified industrial or commercial fertilizer system.',
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        isDarkMode: isDarkMode,
                      ),

                      _buildTermCard(
                        title: '2. User Roles',
                        content:
                            'The System supports the following user roles:\n• Admin – Has full access to system management, monitoring, calibration, emergency handling, and user management.\n• Staff/User – Can view compost status, sensor data, and fertilizer readiness.\n• Guest – Limited read-only access to selected system data.\n\nEach user is responsible for maintaining the confidentiality of their account credentials.',
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        isDarkMode: isDarkMode,
                      ),

                      _buildTermCard(
                        title: '3. Acceptable Use',
                        content:
                            'Users agree to use the System only for its intended purposes. You agree not to:\n• Upload or input false, misleading, or manipulated data\n• Attempt to bypass waste filtration, safety mechanisms, or emergency locks\n• Insert non-biodegradable, hard, or prohibited waste into the system\n• Tamper with sensors, hardware, or calibration settings without authorization\n\nViolation of acceptable use may result in account suspension or termination.',
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        isDarkMode: isDarkMode,
                      ),

                      _buildTermCard(
                        title: '4. Waste Handling Disclaimer',
                        content:
                            'NutriBin only supports soft or small biodegradable waste, such as:\n• Food scraps\n• Fruit peels\n• Vegetable leftovers\n\nThe system cannot process:\n• Bones, shells, seeds, thick stems\n• Plastics, metals, glass, or non-biodegradable materials\n\nUsers are responsible for ensuring correct waste input. Improper waste may trigger emergency mode and require manual maintenance.',
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermCard({
    required String title,
    required String content,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        // Dark Mode: Subtle white border, no shadow
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : Border.all(color: Colors.grey.withOpacity(0.2)),
        // Light Mode: Very subtle shadow
        boxShadow: isDarkMode
            ? []
            : [
                const BoxShadow(
                  blurRadius: 4,
                  color: Color(0x0D000000),
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.interTight(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: subTextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
