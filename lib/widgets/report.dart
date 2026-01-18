import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MachineErrorReportCard extends StatefulWidget {
  const MachineErrorReportCard({super.key});

  @override
  State<MachineErrorReportCard> createState() => _MachineErrorReportCardState();
}

class _MachineErrorReportCardState extends State<MachineErrorReportCard> {
  // Track which error is expanded (only one at a time)
  int? _expandedIndex;

  final List<Map<String, String>> _errors = [
    {
      'title': 'Camera Sensor Malfunction',
      'timestamp': 'Today, 6:20pm',
      'details':
          'Camera sensor failed to detect waste properly. Please check camera alignment and clean the lens. System will retry in 5 minutes.',
    },
    {
      'title': 'Lid Servo Not Responding',
      'timestamp': 'Today, 5:45pm',
      'details':
          'The lid servo motor is not responding to commands. Check power connection and servo calibration. Manual reset may be required.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Color(0x33000000),
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFF44336),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Machine Error Report',
                            style: GoogleFonts.interTight(
                              color: const Color(0xFF57636C),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Critical issues requiring attention',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF57636C),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _errors.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E3E7),
                ),
                itemBuilder: (context, index) {
                  final error = _errors[index];
                  final isExpanded = _expandedIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? const Color(0xFFFFEBEE)
                          : Colors.white,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                width: 4,
                                height: isExpanded ? 120 : 76,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF44336),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  8,
                                  12,
                                  16,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            error['title']!,
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF57636C),
                                              fontSize: 14,
                                              fontWeight: isExpanded
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: const Color(0xFF57636C),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Color(0xFF57636C),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            error['timestamp']!,
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF57636C),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedCrossFade(
                                      firstChild: const SizedBox.shrink(),
                                      secondChild: Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFFF44336,
                                              ).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            error['details']!,
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF57636C),
                                              fontSize: 13,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      crossFadeState: isExpanded
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      duration: const Duration(
                                        milliseconds: 200,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
