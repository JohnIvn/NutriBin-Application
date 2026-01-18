import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/widgets/report.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _expandedFertilizerIndex;
  int? _expandedMachineReportIndex;

  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _secondaryColor => Theme.of(context).colorScheme.secondary;
  Color get _tertiaryColor => Theme.of(context).colorScheme.tertiary;
  Color get _secondaryText =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;

  final List<Map<String, dynamic>> _fertilizerData = [
    {
      'title': 'Balanced fertilizer (10:10:8)',
      'description': 'Suitable for leafy and fruit growth.',
      'fruits': ['Tomato', 'Cucumber', 'Bell Pepper', 'Strawberry'],
      'details':
          'NPK ratio 10:10:8 provides balanced nutrition. Nitrogen promotes leaf growth, phosphorus supports root development, and potassium enhances fruit quality. Apply every 2 weeks during growing season.',
    },
  ];

  final List<Map<String, String>> _machineReports = [
    {
      'title': 'Camera',
      'description': 'Valid Waste Disposed, No Issues Found',
      'timeLabel': 'Date:',
      'time': 'Today, 6:20pm',
      'details':
          'Camera sensor successfully identified and classified waste as valid organic material. Image processing completed in 1.2 seconds with 98% confidence. Total items processed today: 47.',
    },
    {
      'title': 'Servos',
      'description': 'Lid Servo Calibrated, No Issues Found',
      'timeLabel': 'Due:',
      'time': 'Today, 7:34pm',
      'details':
          'Lid servo motor operating within normal parameters. Last calibration completed successfully. Response time: 0.8 seconds. Total cycles today: 52. Next maintenance due in 14 days.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _secondaryBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                MachineErrorReportCard(),
                _fertilizerStatusCard(),
                _buildMachineReportsCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fertilizerStatusCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 2,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Fertilizer Status',
                      style: GoogleFonts.interTight(
                        color: const Color(0xFF57636C),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Ready',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _fertilizerData.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E3E7),
                ),
                itemBuilder: (context, index) {
                  final fertilizer = _fertilizerData[index];
                  final isExpanded = _expandedFertilizerIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? const Color(0xFFF1F8F6)
                          : Colors.white,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _expandedFertilizerIndex = isExpanded ? null : index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    fertilizer['title']!,
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
                            const SizedBox(height: 8),
                            Text(
                              fertilizer['description']!,
                              style: const TextStyle(
                                color: Color(0xFF57636C),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: (fertilizer['fruits'] as List<String>)
                                  .map(
                                    (fruit) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F7FA),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        fruit,
                                        style: const TextStyle(
                                          color: Color(0xFF00796B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF00796B,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    fertilizer['details']!,
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
                              duration: const Duration(milliseconds: 200),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineReportsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child:
          Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Machine Reports',
                            style: GoogleFonts.interTight(
                              color: _tertiaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Recent reports from the sensors',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF57636C),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _machineReports.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE0E3E7),
                        ),
                        itemBuilder: (context, index) {
                          final report = _machineReports[index];
                          final isExpanded =
                              _expandedMachineReportIndex == index;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? const Color(0xFFF5F5F5)
                                  : Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedMachineReportIndex = isExpanded
                                      ? null
                                      : index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Container(
                                        width: 4,
                                        height: isExpanded ? 140 : 76,
                                        decoration: BoxDecoration(
                                          color: _primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  report['title']!,
                                                  style: GoogleFonts.inter(
                                                    color: const Color(
                                                      0xFF57636C,
                                                    ),
                                                    fontSize: 12,
                                                    fontWeight: isExpanded
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                                Icon(
                                                  isExpanded
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                            .keyboard_arrow_down,
                                                  color: const Color(
                                                    0xFF57636C,
                                                  ),
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                report['description']!,
                                                style: GoogleFonts.inter(
                                                  color: const Color(
                                                    0xFF57636C,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    report['timeLabel']!,
                                                    style: GoogleFonts.inter(
                                                      color: const Color(
                                                        0xFF57636C,
                                                      ),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    report['time']!,
                                                    style: GoogleFonts.inter(
                                                      color: const Color(
                                                        0xFF57636C,
                                                      ),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            AnimatedCrossFade(
                                              firstChild:
                                                  const SizedBox.shrink(),
                                              secondChild: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    border: Border.all(
                                                      color: _primaryColor
                                                          .withOpacity(0.3),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    report['details']!,
                                                    style: GoogleFonts.inter(
                                                      color: const Color(
                                                        0xFF57636C,
                                                      ),
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
              )
              .animate()
              .fadeIn(curve: Curves.easeInOut, duration: 300.ms)
              .moveY(
                curve: Curves.easeInOut,
                begin: 20,
                end: 0,
                duration: 300.ms,
              ),
    );
  }
}
