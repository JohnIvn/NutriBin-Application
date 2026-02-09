import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nutribin_application/pages/home/register_machine_page.dart';

class MachineSelectionPage extends StatelessWidget {
  const MachineSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryBackground = Theme.of(context).scaffoldBackgroundColor;

    // Template/fake machines
    final List<Map<String, String>> machines = [
      {'id': 'NB-001', 'name': 'Kitchen NutriBin'},
      {'id': 'NB-002', 'name': 'Cafeteria Bin'},
      {'id': 'NB-003', 'name': 'Office NutriBin'},
    ];

    return Scaffold(
      backgroundColor: secondaryBackground,
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
                color: primaryColor,
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
                  'Select Machine',
                  style: GoogleFonts.interTight(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF57636C),
                  ),
                ).animate().fadeIn(duration: 300.ms).moveY(begin: 20, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Choose a NutriBin machine to manage',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF57636C),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                const SizedBox(height: 24),
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // if inside SingleChildScrollView
                  itemCount: machines.length + 1,
                  itemBuilder: (context, index) {
                    if (index == machines.length) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAddMachineCard(context, primaryColor),
                      );
                    }

                    final machine = machines[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMachineCard(
                        context: context,
                        machineId: machine['id']!,
                        machineName: machine['name']!,
                        primaryColor: primaryColor,
                        index: index,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMachineCard({
    required BuildContext context,
    required String machineId,
    required String machineName,
    required Color primaryColor,
    required int index,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
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
                  // Icon on the left
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.restore_from_trash,
                      size: 26,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name & ID in a Column
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
                            color: const Color(0xFF57636C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          machineId,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF57636C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildAddMachineCard(BuildContext context, Color primaryColor) {
    return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterMachinePage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16), // same padding as machine cards
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 40, color: primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Register Machine',
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
