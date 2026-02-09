import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- APP BAR COLORS ---
    final appBarBg = isDarkMode ? cardColor : primaryColor;
    const appBarTitleColor = Colors.white;
    const appBarSubtitleColor = Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,

        // Status Bar: Always Light (White icons)
        systemOverlayStyle: SystemUiOverlayStyle.light,

        // Bottom Border: REMOVED (Transparent)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.transparent, height: 1.0),
        ),

        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/Logo (Img).png', height: 42),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NutriBin',
                    style: GoogleFonts.interTight(
                      color: appBarTitleColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'User Guide',
                    style: GoogleFonts.inter(
                      color: appBarSubtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'How to use',
                style: GoogleFonts.interTight(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ).animate().fadeIn(duration: 300.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 8),

              Text(
                'Learn how to make the most of your NutriBin experience',
                style: GoogleFonts.inter(fontSize: 16, color: subTextColor),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: 32),

              // Getting Started Section
              _buildSection(
                context: context,
                title: 'Getting Started',
                icon: Icons.rocket_launch_rounded,
                color: Colors.blue,
                textColor: textColor,
                cardColor: cardColor,
                subTextColor: subTextColor,
                isDarkMode: isDarkMode,
                items: [
                  GuideItem(
                    title: 'Register Your Machine',
                    description:
                        'Tap "Add Machine" on the home screen. Enter device ID, name, location, and notes.',
                    icon: Icons.add_circle_outline_rounded,
                  ),
                  GuideItem(
                    title: 'Select a Machine',
                    description:
                        'Tap any registered machine card to view its dashboard and start tracking waste.',
                    icon: Icons.touch_app_rounded,
                  ),
                ],
                delay: 200,
              ),

              // Machine Management Section
              _buildSection(
                context: context,
                title: 'Machine Management',
                icon: Icons.settings_rounded,
                color: Colors.green,
                textColor: textColor,
                cardColor: cardColor,
                subTextColor: subTextColor,
                isDarkMode: isDarkMode,
                items: [
                  GuideItem(
                    title: 'View Machine Status',
                    description:
                        'Monitor status: Online, Offline, or Maintenance directly from the card.',
                    icon: Icons.info_outline_rounded,
                  ),
                  GuideItem(
                    title: 'Edit Details',
                    description:
                        'Update name, location, or description via machine settings.',
                    icon: Icons.edit_rounded,
                  ),
                ],
                delay: 300,
              ),

              // Dashboard Features
              _buildSection(
                context: context,
                title: 'Dashboard Features',
                icon: Icons.dashboard_rounded,
                color: Colors.orange,
                textColor: textColor,
                cardColor: cardColor,
                subTextColor: subTextColor,
                isDarkMode: isDarkMode,
                items: [
                  GuideItem(
                    title: 'Statistics Overview',
                    description:
                        'View real-time stats: total waste, compost ready, and weekly trends.',
                    icon: Icons.bar_chart_rounded,
                  ),
                  GuideItem(
                    title: 'Add Waste Entry',
                    description:
                        'Record deposits with type, weight, and time for accurate tracking.',
                    icon: Icons.add_box_outlined,
                  ),
                ],
                delay: 400,
              ),

              // Troubleshooting
              _buildSection(
                context: context,
                title: 'Troubleshooting',
                icon: Icons.build_circle_outlined,
                color: Colors.redAccent,
                textColor: textColor,
                cardColor: cardColor,
                subTextColor: subTextColor,
                isDarkMode: isDarkMode,
                items: [
                  GuideItem(
                    title: 'Machine Offline',
                    description:
                        'Check power and Wi-Fi. Restart device if necessary.',
                    icon: Icons.wifi_off_rounded,
                  ),
                  GuideItem(
                    title: 'Syncing Issues',
                    description:
                        'Ensure stable internet. Pull down to refresh data.',
                    icon: Icons.sync_problem_rounded,
                  ),
                ],
                delay: 500,
              ),

              const SizedBox(height: 32),

              // Help Card
              _buildHelpCard(context, primaryColor, textColor, isDarkMode),

              const SizedBox(height: 80),
            ],
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
    required Color textColor,
    required Color subTextColor,
    required Color cardColor,
    required bool isDarkMode,
    required List<GuideItem> items,
    required int delay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(duration: 300.ms, delay: delay.ms)
            .moveX(begin: -10, end: 0, delay: delay.ms),

        const SizedBox(height: 16),

        // Cards
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                _buildGuideCard(
                      item: item,
                      accentColor: color,
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isDarkMode: isDarkMode,
                    )
                    .animate()
                    .fadeIn(
                      duration: 300.ms,
                      delay: (delay + 100 + (index * 50)).ms,
                    )
                    .moveY(
                      begin: 10,
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
    required GuideItem item,
    required Color accentColor,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        // Dark Mode: Subtle white border, no shadow
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : null,
        // Light Mode: Subtle shadow, no border
        boxShadow: isDarkMode
            ? []
            : [
                const BoxShadow(
                  blurRadius: 4,
                  color: Color(0x1A000000),
                  offset: Offset(0, 2),
                ),
              ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(isDarkMode ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: accentColor, size: 22),
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
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: subTextColor,
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

  Widget _buildHelpCard(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    bool isDarkMode,
  ) {
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: primaryColor.withOpacity(0.3),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
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
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Support contact - Coming Soon'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.email_outlined),
                  label: Text(
                    'Contact Support',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: 600.ms)
        .scale(begin: const Offset(0.95, 0.95), delay: 600.ms);
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
