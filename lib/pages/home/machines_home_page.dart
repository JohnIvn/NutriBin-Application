import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nutribin_application/pages/home/register_machine_page.dart';

class MachineSelectionPage extends StatelessWidget {
  const MachineSelectionPage({super.key});

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

    // --- VISIBILITY COLORS ---
    final highlightColor = isDarkMode
        ? Theme.of(context).colorScheme.tertiary
        : primaryColor;

    // --- APP BAR COLORS ---
    final appBarBg = isDarkMode ? cardColor : primaryColor;
    const appBarTitleColor = Colors.white;
    const appBarSubtitleColor = Colors.white70;

    // Template/fake machines
    final List<Map<String, String>> machines = [
      {'id': 'NB-001', 'name': 'Kitchen NutriBin'},
      {'id': 'NB-002', 'name': 'Cafeteria Bin'},
      {'id': 'NB-003', 'name': 'Office NutriBin'},
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,

        systemOverlayStyle: SystemUiOverlayStyle.light,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.transparent,
            height: 1.0,
          ),
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
                    'Machine Manager',
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
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 8),
                child: Row(
                  children: [
                    Text(
                      'Your Machines',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: highlightColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${machines.length} Active',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: highlightColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Machine List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: machines.length + 1,
                itemBuilder: (context, index) {
                  if (index == machines.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAddMachineCard(
                        context,
                        highlightColor,
                        isDarkMode,
                      ),
                    );
                  }

                  final machine = machines[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMachineCard(
                      context: context,
                      machineId: machine['id']!,
                      machineName: machine['name']!,
                      highlightColor: highlightColor,
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      index: index,
                      isDarkMode: isDarkMode,
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineCard({
    required BuildContext context,
    required String machineId,
    required String machineName,
    required Color highlightColor,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required int index,
    required bool isDarkMode,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: isDarkMode
                ? Border.all(color: Colors.white.withOpacity(0.05))
                : null,
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: highlightColor.withOpacity(
                          isDarkMode ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.restore_from_trash,
                        size: 26,
                        color:
                            highlightColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            machineName,
                            style: GoogleFonts.interTight(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            machineId,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: subTextColor.withOpacity(0.5),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: ((index * 50).clamp(0, 500)).ms)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1));
  }

  Widget _buildAddMachineCard(
    BuildContext context,
    Color highlightColor,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: highlightColor.withOpacity(isDarkMode ? 0.05 : 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlightColor.withOpacity(0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterMachinePage(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 24,
                  color: highlightColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Register New Machine',
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: highlightColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }
}
