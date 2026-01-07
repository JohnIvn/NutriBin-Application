import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION
            Container(
              height: 500,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/CompostImg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.bottomCenter,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 64),
                    Text(
                      'TURN FOOD WASTE INTO\nNUTRIENT RICH-GOLD',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF101213),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A smart, IoT-powered solution designed to convert small-scale food waste into nutrient-dense fertilizer.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // SIGN IN BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                icon: const Icon(Icons.mail_outline),
                label: const Text('Sign in'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // FEATURES
            Text(
              'Key Features',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            _featureCard(
              context,
              Icons.auto_mode,
              'Automated Processing',
              'Optimized Waste Conversion',
            ),
            _featureCard(
              context,
              Icons.access_time,
              'Realtime Monitoring',
              'Track NPK, pH & Temp levels',
            ),
            _featureCard(
              context,
              Icons.analytics,
              'Nutrient Analysis',
              'Know your fertilizer’s quality',
            ),

            const SizedBox(height: 24),

            // ABOUT
            Text(
              'About Us',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/FarmImg.png',
                width: 300,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'NutriBin is a smart, technologically advanced method for producing organic fertilizer and managing trash sustainably.',
                textAlign: TextAlign.justify,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
              ),
            ),

            const SizedBox(height: 48),

            Container(
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // About Us
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print('About Us pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white, // text/icon color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('About Us'),
                    ),
                  ),

                  // FAQs
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print('FAQs pressed');
                        Navigator.pushNamed(context, '/support');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Support'),
                    ),
                  ),

                  // Terms of Service
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/termsOfService');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Terms of Service'),
                    ),
                  ),

                  // Studies
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print('Studies pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Studies'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 72, color: Theme.of(context).primaryColor),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
