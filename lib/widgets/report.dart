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

  void _handleReportError(String errorTitle) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report Error',
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Error report for "$errorTitle" has been submitted to the maintenance team.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final dividerColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFFE0E3E7);
    final errorColor = const Color(0xFFF44336);
    final warningColor = const Color(0xFFFF9800);
    final expandedBgColor = isDarkMode
        ? errorColor.withOpacity(0.1)
        : const Color(0xFFFFEBEE);
    final tipBgColor = isDarkMode
        ? warningColor.withOpacity(0.1)
        : const Color(0xFFFFF3E0);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : const Color(0x33000000);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: shadowColor,
              offset: const Offset(0, 1),
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
                          Icon(
                            Icons.warning_amber_rounded,
                            color: errorColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Machine Error Report',
                            style: GoogleFonts.interTight(
                              color: textColor,
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
                          color: subTextColor,
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
                separatorBuilder: (context, index) =>
                    Divider(height: 1, thickness: 1, color: dividerColor),
                itemBuilder: (context, index) {
                  final error = _errors[index];
                  final isExpanded = _expandedIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isExpanded ? expandedBgColor : cardColor,
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
                                height: isExpanded ? 230 : 76,
                                decoration: BoxDecoration(
                                  color: errorColor,
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
                                              color: textColor,
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
                                          color: subTextColor,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: subTextColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            error['timestamp']!,
                                            style: GoogleFonts.inter(
                                              color: subTextColor,
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: errorColor.withOpacity(
                                                    0.3,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                error['details']!,
                                                style: GoogleFonts.inter(
                                                  color: textColor,
                                                  fontSize: 13,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Tip container
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: tipBgColor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: warningColor
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.lightbulb_outline,
                                                    color: warningColor,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Tip:',
                                                          style:
                                                              GoogleFonts.inter(
                                                                color:
                                                                    warningColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Try restarting the device twice before filing a report. This often resolves temporary sensor and connection issues.',
                                                          style:
                                                              GoogleFonts.inter(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                height: 1.4,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Report button
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _handleReportError(
                                                      error['title']!,
                                                    ),
                                                icon: const Icon(
                                                  Icons.report_problem_outlined,
                                                  size: 18,
                                                ),
                                                label: Text(
                                                  'Report This Error',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: errorColor,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                          ],
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
