import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactWidget extends StatefulWidget {
  const ContactWidget({super.key});

  static String routeName = 'Support';
  static String routePath = '/support';

  @override
  State<ContactWidget> createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

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

    // Create 7 animations (3 for top cards + 4 for FAQ cards)
    _fadeAnimations = List.generate(
      7,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            (0.6 + index * 0.1).clamp(0.0, 1.0),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    _slideAnimations = List.generate(
      7,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                (0.6 + index * 0.1).clamp(0.0, 1.0),
                curve: Curves.easeInOut,
              ),
            ),
          ),
    );

    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedContainer({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimations[index].value,
          child: Opacity(opacity: _fadeAnimations[index].value, child: child),
        );
      },
      child: child,
    );
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
              'Contact Us',
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
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to support',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _secondaryText,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'How can we help you?',
                            style: GoogleFonts.interTight(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: _secondaryText,
                            ),
                          ),
                        ),

                        // Contact Options Row
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Call Us
                              Expanded(
                                child: _buildAnimatedContainer(
                                  index: 0,
                                  child: Container(
                                    width: 120,
                                    constraints: const BoxConstraints(
                                      maxWidth: 500,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _secondaryBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.local_phone,
                                            color: _primaryColor,
                                            size: 36,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: Text(
                                              'Call Us',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: _secondaryText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Email Us
                              Expanded(
                                child: _buildAnimatedContainer(
                                  index: 1,
                                  child: Container(
                                    width: 120,
                                    constraints: const BoxConstraints(
                                      maxWidth: 500,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _secondaryBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            color: _primaryColor,
                                            size: 36,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: Text(
                                              'Email Us',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: _secondaryText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Search FAQs
                              Expanded(
                                child: _buildAnimatedContainer(
                                  index: 2,
                                  child: Container(
                                    width: 120,
                                    constraints: const BoxConstraints(
                                      maxWidth: 500,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _secondaryBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_rounded,
                                            color: _primaryColor,
                                            size: 36,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: Text(
                                              'Search FAQs',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: _secondaryText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // FAQ Section Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                          child: Text(
                            'Review FAQ\'s below',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _secondaryText,
                            ),
                          ),
                        ),

                        // FAQ 1
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildAnimatedContainer(
                            index: 3,
                            child: _buildFAQCard(
                              question: 'What does the compost bin system do?',
                              answer:
                                  'The compost bin system helps convert organic waste like food scraps and garden waste into nutrient-rich compost, reducing landfill waste and creating a natural fertilizer for plants.',
                            ),
                          ),
                        ),

                        // FAQ 2
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildAnimatedContainer(
                            index: 4,
                            child: _buildFAQCard(
                              question:
                                  'What types of waste can be placed in the compost bin?',
                              answer:
                                  'You can place fruit and vegetable scraps, coffee grounds, eggshells, garden clippings, and other biodegradable organic materials. Avoid meat, dairy, and oily foods as they can attract pests.',
                            ),
                          ),
                        ),

                        // FAQ 3
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildAnimatedContainer(
                            index: 5,
                            child: _buildFAQCard(
                              question:
                                  'How does the system monitor the composting process?',
                              answer:
                                  'The system uses sensors to monitor temperature, moisture, and aeration levels to ensure optimal composting conditions, providing notifications if adjustments are needed.',
                            ),
                          ),
                        ),

                        // FAQ 4
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: _buildAnimatedContainer(
                            index: 6,
                            child: _buildFAQCard(
                              question:
                                  'Does the compost bin require regular maintenance?',
                              answer:
                                  'Yes, regular maintenance involves adding the right mix of green and brown materials, stirring or turning the compost, and checking sensor readings to maintain proper conditions for decomposition.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard({required String question, required String answer}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: _secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _secondaryText,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                answer,
                style: GoogleFonts.inter(fontSize: 14, color: _secondaryText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
