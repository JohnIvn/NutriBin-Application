import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  Color _getPrimaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  Color _getSecondaryBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getSecondaryBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset('assets/images/Logo (Img).png', height: 48),
            const SizedBox(width: 8),
            Text(
              'NutriBin',
              textAlign: TextAlign.left,
              style: GoogleFonts.interTight(
                color: _getPrimaryColor(context),
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Guide',
                  style: GoogleFonts.interTight(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF57636C),
                  ),
                ).animate().fadeIn(duration: 300.ms).moveY(begin: 20, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Learn how to make the most of your NutriBin experience',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF57636C),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                const SizedBox(height: 32),

                // Getting Started Section
                _buildSection(
                  context: context,
                  title: 'Getting Started',
                  icon: Icons.rocket_launch,
                  color: Colors.blue,
                  items: [
                    GuideItem(
                      title: 'Register Your Machine',
                      description:
                          'Tap the "Add Machine" button on the home screen to register your NutriBin device. Enter the device ID, name, location, and any additional notes.',
                      icon: Icons.add_circle_outline,
                    ),
                    GuideItem(
                      title: 'Select a Machine',
                      description:
                          'Tap on any registered machine card to view its dashboard and start tracking waste management.',
                      icon: Icons.touch_app,
                    ),
                    GuideItem(
                      title: 'Navigate the App',
                      description:
                          'Use the bottom navigation bar to switch between Home, Guide, and Account sections.',
                      icon: Icons.navigation,
                    ),
                  ],
                  delay: 200,
                ),

                // Machine Management Section
                _buildSection(
                  context: context,
                  title: 'Machine Management',
                  icon: Icons.settings,
                  color: Colors.green,
                  items: [
                    GuideItem(
                      title: 'View Machine Status',
                      description:
                          'Each machine displays its current status: Online, Offline, or Maintenance. Monitor your devices at a glance.',
                      icon: Icons.info_outline,
                    ),
                    GuideItem(
                      title: 'Edit Machine Details',
                      description:
                          'Update machine information like name, location, or description through the machine settings.',
                      icon: Icons.edit,
                    ),
                    GuideItem(
                      title: 'Delete a Machine',
                      description:
                          'Tap the three-dot menu on a machine card and select "Delete" to remove it from your account.',
                      icon: Icons.delete_outline,
                    ),
                  ],
                  delay: 300,
                ),

                // Dashboard Features Section
                _buildSection(
                  context: context,
                  title: 'Dashboard Features',
                  icon: Icons.dashboard,
                  color: Colors.orange,
                  items: [
                    GuideItem(
                      title: 'Statistics Overview',
                      description:
                          'View real-time statistics including total waste, compost ready, weekly trends, and efficiency metrics.',
                      icon: Icons.bar_chart,
                    ),
                    GuideItem(
                      title: 'Add Waste Entry',
                      description:
                          'Record new waste deposits with details like type, weight, and timestamp for accurate tracking.',
                      icon: Icons.add_box,
                    ),
                    GuideItem(
                      title: 'View History',
                      description:
                          'Access complete history of all waste entries and composting activities for your machine.',
                      icon: Icons.history,
                    ),
                  ],
                  delay: 400,
                ),

                // Tips & Best Practices Section
                _buildSection(
                  context: context,
                  title: 'Tips & Best Practices',
                  icon: Icons.lightbulb_outline,
                  color: Colors.purple,
                  items: [
                    GuideItem(
                      title: 'Regular Monitoring',
                      description:
                          'Check your machine dashboard regularly to track waste accumulation and compost readiness.',
                      icon: Icons.schedule,
                    ),
                    GuideItem(
                      title: 'Proper Waste Sorting',
                      description:
                          'Ensure only compostable materials are added to maintain optimal composting efficiency.',
                      icon: Icons.eco,
                    ),
                    GuideItem(
                      title: 'Maintenance Schedule',
                      description:
                          'Set machines to maintenance mode when performing cleaning or repairs to keep accurate records.',
                      icon: Icons.build,
                    ),
                  ],
                  delay: 500,
                ),

                // Troubleshooting Section
                _buildSection(
                  context: context,
                  title: 'Troubleshooting',
                  icon: Icons.help_outline,
                  color: Colors.red,
                  items: [
                    GuideItem(
                      title: 'Machine Offline',
                      description:
                          'Check power connection and network connectivity. Restart the device if necessary.',
                      icon: Icons.wifi_off,
                    ),
                    GuideItem(
                      title: 'Syncing Issues',
                      description:
                          'Ensure you have a stable internet connection. Pull down to refresh the data.',
                      icon: Icons.sync_problem,
                    ),
                    GuideItem(
                      title: 'App Support',
                      description:
                          'Contact support through the Account section if you encounter persistent issues.',
                      icon: Icons.support_agent,
                    ),
                  ],
                  delay: 600,
                ),

                const SizedBox(height: 32),

                // Need More Help Card
                Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getPrimaryColor(context),
                            _getPrimaryColor(context).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Color(0x33000000),
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.help_center,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Need More Help?',
                              style: GoogleFonts.interTight(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Contact our support team for personalized assistance',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Support contact - Coming Soon',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _getPrimaryColor(context),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: Icon(Icons.email),
                              label: Text(
                                'Contact Support',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 700.ms)
                    .scale(begin: const Offset(0.9, 0.9), delay: 700.ms),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<GuideItem> items,
    required int delay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.interTight(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF57636C),
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(duration: 300.ms, delay: delay.ms)
            .moveX(begin: -20, end: 0, delay: delay.ms),
        const SizedBox(height: 16),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                _buildGuideCard(
                      context: context,
                      item: item,
                      accentColor: color,
                    )
                    .animate()
                    .fadeIn(
                      duration: 300.ms,
                      delay: (delay + 100 + (index * 50)).ms,
                    )
                    .moveY(
                      begin: 20,
                      end: 0,
                      delay: (delay + 100 + (index * 50)).ms,
                    ),
          );
        }).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGuideCard({
    required BuildContext context,
    required GuideItem item,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF57636C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF57636C),
                      height: 1.5,
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
}

class GuideItem {
  final String title;
  final String description;
  final IconData icon;

  GuideItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
