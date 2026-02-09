import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MachineSelectionPage extends StatelessWidget {
  const MachineSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryBackground = Theme.of(context).scaffoldBackgroundColor;

    // Template/fake machines
    final List<Map<String, String>> machines = [
      {
        'id': 'NB-001',
        'name': 'Kitchen NutriBin',
        'location': 'Building A, Floor 2',
      },
      {
        'id': 'NB-002',
        'name': 'Cafeteria Bin',
        'location': 'Main Building, Ground Floor',
      },
      {
        'id': 'NB-003',
        'name': 'Office NutriBin',
        'location': 'Building B, Floor 3',
      },
      {
        'id': 'NB-004',
        'name': 'Lab Composter',
        'location': 'Research Wing, Floor 1',
      },
      {'id': 'NB-005', 'name': 'Garden Bin', 'location': 'Outdoor Area'},
      {'id': 'NB-006', 'name': 'Warehouse Unit', 'location': 'Storage Area'},
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: machines.length,
                  itemBuilder: (context, index) {
                    final machine = machines[index];
                    return _buildMachineCard(
                      context: context,
                      machineId: machine['id']!,
                      machineName: machine['name']!,
                      location: machine['location']!,
                      primaryColor: primaryColor,
                      index: index,
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
    required String location,
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
              // Navigate to HomePage when tapped
              Navigator.pushNamed(context, '/machines');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restore_from_trash,
                      size: 32,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Machine Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machineName,
                        style: GoogleFonts.interTight(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF57636C),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF57636C),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tag,
                              size: 12,
                              color: const Color(0xFF57636C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              machineId,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF57636C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          curve: Curves.easeInOut,
          duration: 300.ms,
          delay: (index * 50).ms,
        )
        .scale(
          curve: Curves.easeInOut,
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          delay: (index * 50).ms,
        );
  }
}
