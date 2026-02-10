import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAcceptancePage extends StatefulWidget {
  const TermsAcceptancePage({super.key});

  static String routeName = 'TermsAcceptance';
  static String routePath = '/termsAcceptance';

  @override
  State<TermsAcceptancePage> createState() => _TermsAcceptancePageState();
}

class _TermsAcceptancePageState extends State<TermsAcceptancePage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  // Color scheme
  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _surfaceColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1C2420)
      : Colors.white;
  Color get _secondaryText => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFB5C1B8)
      : const Color(0xFF57636C);
  Color get _primaryText => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF101213);
  Color get _borderColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withOpacity(0.05)
      : Colors.grey[300]!;
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 50.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    // Start animation
    _animationController.forward();

    // Listen to scroll position
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // Consider "bottom" as being within 100 pixels of the actual bottom
      if (currentScroll >= maxScroll - 100 && !_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleAccept() {
    Navigator.pop(context, true);
  }

  void _handleDecline() {
    Navigator.pop(context, false);
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
          backgroundColor: _isDarkMode ? _secondaryBackground : _primaryColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close, size: 24),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          title: Text(
            'Terms of Service',
            style: GoogleFonts.interTight(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: _slideAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _surfaceColor,
                            border: Border(
                              bottom: BorderSide(color: _borderColor, width: 1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/Logo (Img).png',
                                      width: 40,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NutriBin',
                                          style: GoogleFonts.interTight(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w600,
                                            color: _primaryText,
                                          ),
                                        ),
                                        Text(
                                          'Excess Food Composting and Fertilizer Monitoring System',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: _primaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Last Updated: January 2026',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _isDarkMode
                                        ? const Color(0xFF8FAE8F)
                                        : _primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Introduction
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'By accessing or using the NutriBin web application, hardware system, or any related services (collectively referred to as the "System"), you agree to be bound by these Terms of Service. If you do not agree to these terms, you must not use the System.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.6,
                              color: _secondaryText,
                            ),
                          ),
                        ),

                        // Terms sections
                        _buildTermSection(
                          number: '1',
                          title: 'Purpose of the System',
                          content:
                              'NutriBin is designed to monitor and manage the composting of soft or small biodegradable waste for fertilizer production. The System provides real-time sensor data, status monitoring, logging, and alerts related to compost quality and safety.\n\nNutriBin is intended for educational, research, and prototype demonstration purposes and is not a certified industrial or commercial fertilizer system.',
                        ),

                        _buildTermSection(
                          number: '2',
                          title: 'User Roles',
                          content:
                              'The System supports the following user roles:\n\n• Admin – Has full access to system management, monitoring, calibration, emergency handling, and user management.\n\n• Staff/User – Can view compost status, sensor data, and fertilizer readiness.\n\n• Guest – Limited read-only access to selected system data.\n\nEach user is responsible for maintaining the confidentiality of their account credentials.',
                        ),

                        _buildTermSection(
                          number: '3',
                          title: 'Acceptable Use',
                          content:
                              'Users agree to use the System only for its intended purposes. You agree not to:\n\n• Upload or input false, misleading, or manipulated data\n\n• Attempt to bypass waste filtration, safety mechanisms, or emergency locks\n\n• Insert non-biodegradable, hard, or prohibited waste into the system\n\n• Tamper with sensors, hardware, or calibration settings without authorization\n\n• Attempt unauthorized access to admin or restricted features\n\nViolation of acceptable use may result in account suspension or termination.',
                        ),

                        _buildTermSection(
                          number: '4',
                          title: 'Waste Handling Disclaimer',
                          content:
                              'NutriBin only supports soft or small biodegradable waste, such as:\n\n• Food scraps\n• Fruit peels\n• Vegetable leftovers\n\nThe system cannot process:\n\n• Bones, shells, seeds, thick stems\n• Plastics, metals, glass, or non-biodegradable materials\n\nUsers are responsible for ensuring correct waste input. Improper waste may trigger emergency mode and require manual maintenance.',
                        ),

                        _buildTermSection(
                          number: '5',
                          title: 'Data Privacy and Security',
                          content:
                              'We collect and process user data in accordance with applicable privacy laws. Your personal information will be used solely for system operation, monitoring, and communication purposes. We implement industry-standard security measures to protect your data.',
                        ),

                        _buildTermSection(
                          number: '6',
                          title: 'Limitation of Liability',
                          content:
                              'NutriBin is provided "as is" without warranties of any kind. The developers and operators are not liable for any damages arising from system malfunction, data loss, or improper use. Users assume all risks associated with using the System.',
                        ),

                        _buildTermSection(
                          number: '7',
                          title: 'Modifications to Terms',
                          content:
                              'We reserve the right to modify these Terms of Service at any time. Users will be notified of significant changes. Continued use of the System after modifications constitutes acceptance of the updated terms.',
                        ),

                        const SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom action buttons
              Container(
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_hasScrolledToBottom)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: _secondaryText,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Please scroll to read all terms',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _secondaryText,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _handleDecline,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                                side: BorderSide(
                                  color: _isDarkMode
                                      ? _primaryText
                                      : _secondaryText,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Decline',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _isDarkMode
                                      ? _primaryText
                                      : _secondaryText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _hasScrolledToBottom
                                  ? _handleAccept
                                  : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                                backgroundColor: _primaryColor,
                                disabledBackgroundColor: _isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                                elevation: _hasScrolledToBottom ? 3 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Accept Terms',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _hasScrolledToBottom
                                      ? Colors.white
                                      : (_isDarkMode
                                            ? Colors.grey[600]
                                            : Colors.grey[500]),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildTermSection({
    required String number,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 1),
          boxShadow: _isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: _primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
