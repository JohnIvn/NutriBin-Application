import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/widgets/report.dart';
import 'package:nutribin_application/services/machine_service.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  final String machineId;
  const DashboardPage({super.key, required this.machineId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _expandedMachineReportIndex;
  Timer? _dataRefreshTimer;
  List<Map<String, dynamic>> notifications = [];

  // Loading state
  bool isLoading = true;

  // Real-time sensor data
  Map<String, dynamic> sensorData = {
    'nitrogen': '0.00',
    'phosphorus': '0.00',
    'potassium': '0.00',
    'temperature': '0.00',
    'ph': '0.00',
    'humidity': '0.00',
    'moisture': '0.00',
    'weight_kg': null,
    'reed_switch': null,
    'methane': '0.00',
    'air_quality': null,
    'carbon_monoxide': null,
    'combustible_gases': null,
  };

  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;

  @override
  void initState() {
    super.initState();
    _fetchData(machineId: widget.machineId);
    _startDataRefresh();
    fetchNotifications();
  }

  @override
  void dispose() {
    _dataRefreshTimer?.cancel();
    super.dispose();
  }

  void _startDataRefresh() {
    // Refresh data every 5 seconds
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchData(machineId: widget.machineId);
      fetchNotifications(); // Also refresh notifications
    });
  }

  Future<void> _fetchData({required String machineId}) async {
    try {
      if (machineId == "null" || machineId.toString().isEmpty) {
        _showError("Invalid Machine ID please try again later");
        return;
      }

      final response = await MachineService.fetchFertilizerStatus(
        machineId: machineId,
      );

      if (response['ok'] == true && response['data'] != null) {
        if (mounted) {
          setState(() {
            sensorData = Map<String, dynamic>.from(response['data']);
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showError(e.toString());
      }
    }
  }

  // Generate machine reports based on unresolved error notifications
  List<Map<String, String>> get _machineReports {
    List<Map<String, String>> reports = [];

    // Filter for unresolved error notifications only
    final unresolvedErrors = notifications.where((notification) {
      final type = notification['type']?.toString().toLowerCase() ?? '';
      final resolved = notification['resolved'] ?? false;
      return type == 'error' && !resolved;
    }).toList();

    // Convert notifications to report format
    for (var notification in unresolvedErrors) {
      final dateStr = notification['date'] ?? '';
      String formattedDate = 'N/A';

      try {
        final DateTime dateTime = DateTime.parse(dateStr);
        final now = DateTime.now();
        final difference = now.difference(dateTime);

        if (difference.inMinutes < 60) {
          formattedDate = '${difference.inMinutes}m ago';
        } else if (difference.inHours < 24) {
          formattedDate = '${difference.inHours}h ago';
        } else if (difference.inDays < 7) {
          formattedDate = '${difference.inDays}d ago';
        } else {
          formattedDate = DateFormat('MMM d, yyyy').format(dateTime);
        }
      } catch (e) {
        formattedDate = dateStr;
      }

      reports.add({
        'title': notification['header'] ?? 'Error',
        'description': notification['subheader'] ?? 'Issue detected',
        'timeLabel': 'Detected:',
        'time': formattedDate,
        'details':
            notification['description'] ?? 'No additional details available.',
      });
    }

    // If no unresolved errors, show a "No Issues" report
    if (reports.isEmpty) {
      reports.add({
        'title': 'System Status',
        'description': 'All systems operating normally',
        'timeLabel': 'Last Check:',
        'time': 'Just now',
        'details':
            'No unresolved errors detected. All machine components are functioning within normal parameters.',
      });
    }

    return reports;
  }

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
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: _primaryColor))
              : RefreshIndicator(
                  onRefresh: () => _fetchData(machineId: widget.machineId),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MachineErrorReportCard(notifications: notifications),
                        // _buildMachineReportsCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMachineReportsCard() {
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
    final expandedBgColor = isDarkMode
        ? _primaryColor.withOpacity(0.1)
        : const Color(0xFFF5F5F5);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : const Color(0x33000000);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child:
          Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Machine Reports',
                            style: GoogleFonts.interTight(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Unresolved errors from notifications',
                            style: GoogleFonts.inter(
                              color: subTextColor,
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
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: dividerColor,
                        ),
                        itemBuilder: (context, index) {
                          final report = _machineReports[index];
                          final isExpanded =
                              _expandedMachineReportIndex == index;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isExpanded ? expandedBgColor : cardColor,
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
                                                    color: textColor,
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
                                                  color: subTextColor,
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
                                                  color: subTextColor,
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
                                                      color: subTextColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    report['time']!,
                                                    style: GoogleFonts.inter(
                                                      color: textColor,
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
                                                    color: cardColor,
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
                                                      color: textColor,
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

  void fetchNotifications() async {
    try {
      final response = await MachineService.fetchNotifications(
        machineId: widget.machineId,
      );
      print("RESPONSE: ${response.toString()}");

      if (response['ok'] == true && response['data'] != null) {
        print("NOTIFICATIONS: ${response['data']}");
        if (mounted) {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(response['data']);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            notifications = [];
          });
        }
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    print("DEBUG: $message");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
