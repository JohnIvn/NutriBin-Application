import 'package:flutter/material.dart';
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

  // Color scheme
  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryColor => const Color(0xFF39D2C0);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => const Color(0xFF57636C);

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Text animation (starts at 100ms)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeInOut),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 170.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.1, 0.7, curve: Curves.easeInOut),
          ),
        );

    // List animation (starts at 150ms)
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.75, curve: Curves.easeInOut),
      ),
    );

    _listSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 170.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.15, 0.75, curve: Curves.easeInOut),
          ),
        );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: _secondaryBackground,
        appBar: AppBar(
          backgroundColor: _primaryColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Terms of Service',
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and App Name
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/Logo (Img).png',
                                width: 44.69,
                                height: 71.8,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                'NutriBin',
                                style: GoogleFonts.interTight(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: _secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 4, 0, 0),
                        child: Text(
                          'Excess Food Composting and Fertilizer Monitoring System',
                          textAlign: TextAlign.start,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: _secondaryText,
                          ),
                        ),
                      ),

                      Divider(
                        height: 32,
                        thickness: 1,
                        color: Colors.grey[300],
                      ),

                      // Last Updated
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 0, 0),
                        child: Text(
                          'Last Updated: January 2026',
                          textAlign: TextAlign.start,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _secondaryText,
                          ),
                        ),
                      ),

                      // Introduction Text (Animated)
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
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                          child: Text(
                            'By accessing or using the NutriBin web application, hardware system, or any related services (collectively referred to as the "System"), you agree to be bound by these Terms of Service. If you do not agree to these terms, you must not use the System.',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: _secondaryText,
                            ),
                          ),
                        ),
                      ),

                      // Terms List (Animated)
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
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            children: [
                              // Term 1
                              _buildTermCard(
                                title: '1. Purpose of the System',
                                content:
                                    'NutriBin is designed to monitor and manage the composting of soft or small biodegradable waste for fertilizer production. The System provides real-time sensor data, status monitoring, logging, and alerts related to compost quality and safety.\nNutriBin is intended for educational, research, and prototype demonstration purposes and is not a certified industrial or commercial fertilizer system.',
                              ),

                              // Term 2
                              _buildTermCard(
                                title: '2. User Roles',
                                content:
                                    'The System supports the following user roles:\n- Admin – Has full access to system management, monitoring, calibration, emergency handling, and user management.\n- Staff/User – Can view compost status, sensor data, and fertilizer readiness.\n- Guest – Limited read-only access to selected system data.\nEach user is responsible for maintaining the confidentiality of their account credentials.',
                              ),

                              // Term 3
                              _buildTermCard(
                                title: '3. Acceptable Use',
                                content:
                                    '- Users agree to use the System only for its intended purposes. You agree not to:\n- Upload or input false, misleading, or manipulated data\n- Attempt to bypass waste filtration, safety mechanisms, or emergency locks\n- Insert non-biodegradable, hard, or prohibited waste into the system\n- Tamper with sensors, hardware, or calibration settings without authorization\n- Attempt unauthorized access to admin or restricted features\n- Violation of acceptable use may result in account suspension or termination.',
                              ),

                              // Term 4
                              _buildTermCard(
                                title: '4. Waste Handling Disclaimer',
                                content:
                                    'NutriBin only supports soft or small biodegradable waste, such as:\n- Food scraps\n- Fruit peels\n- Vegetable leftovers\nThe system cannot process:\n- Bones, shells, seeds, thick stems\n- Plastics, metals, glass, or non-biodegradable materials\n\nUsers are responsible for ensuring correct waste input. Improper waste may trigger emergency mode and require manual maintenance.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermCard({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 570),
        decoration: BoxDecoration(
          color: _secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _secondaryText,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  content,
                  style: GoogleFonts.inter(fontSize: 14, color: _secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
