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

  // Generate fertilizer data based on real sensor values
  // ignore: unused_element
  List<Map<String, dynamic>> get _fertilizerData {
    final nitrogen = double.tryParse(sensorData['nitrogen'] ?? '0') ?? 0;
    final phosphorus = double.tryParse(sensorData['phosphorus'] ?? '0') ?? 0;
    final potassium = double.tryParse(sensorData['potassium'] ?? '0') ?? 0;

    final nRatio = (nitrogen / 10).round();
    final pRatio = (phosphorus / 10).round();
    final kRatio = (potassium / 10).round();

    String getFertilizerType() {
      if (nRatio > pRatio && nRatio > kRatio) {
        return 'Nitrogen-rich fertilizer';
      } else if (pRatio > nRatio && pRatio > kRatio) {
        return 'Phosphorus-rich fertilizer';
      } else if (kRatio > nRatio && kRatio > pRatio) {
        return 'Potassium-rich fertilizer';
      } else {
        return 'Balanced fertilizer';
      }
    }

    String getDescription() {
      if (nRatio > pRatio && nRatio > kRatio) {
        return 'Ideal for promoting vigorous leaf and stem growth.';
      } else if (pRatio > nRatio && pRatio > kRatio) {
        return 'Excellent for root development and flowering.';
      } else if (kRatio > nRatio && kRatio > pRatio) {
        return 'Perfect for fruit quality and disease resistance.';
      } else {
        return 'Suitable for leafy and fruit growth.';
      }
    }

    List<String> getRecommendedCrops() {
      if (nRatio > pRatio && nRatio > kRatio) {
        return ['Lettuce', 'Spinach', 'Cabbage', 'Kale'];
      } else if (pRatio > nRatio && pRatio > kRatio) {
        return ['Carrot', 'Onion', 'Garlic', 'Radish'];
      } else if (kRatio > nRatio && kRatio > pRatio) {
        return ['Tomato', 'Pepper', 'Potato', 'Squash'];
      } else {
        return ['Tomato', 'Cucumber', 'Bell Pepper', 'Strawberry'];
      }
    }

    return [
      {
        'title': '${getFertilizerType()} ($nRatio:$pRatio:$kRatio)',
        'description': getDescription(),
        'fruits': getRecommendedCrops(),
        'details':
            'NPK ratio $nRatio:$pRatio:$kRatio provides ${nRatio > pRatio && nRatio > kRatio
                ? 'nitrogen-rich'
                : pRatio > nRatio && pRatio > kRatio
                ? 'phosphorus-rich'
                : kRatio > nRatio && kRatio > pRatio
                ? 'potassium-rich'
                : 'balanced'} nutrition. '
            'Current levels: Nitrogen ${nitrogen.toStringAsFixed(1)}ppm, Phosphorus ${phosphorus.toStringAsFixed(1)}ppm, Potassium ${potassium.toStringAsFixed(1)}ppm. '
            'Apply every 2 weeks during growing season for optimal results.',
      },
    ];
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
                        _fertilizerStatusCard(),
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

  Widget _fertilizerStatusCard() {
    // --- DYNAMIC COLORS ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final accentColor = const Color(0xFF00796B);
    final chipBgColor = isDarkMode
        ? accentColor.withOpacity(0.1)
        : const Color(0xFFE0F7FA);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : const Color(0x33000000);

    final List<String> fruits = [
      'Tomato',
      'Cucumber',
      'Bell Pepper',
      'Strawberry',
    ];

    // --- NPK Values ---
    final nitrogen = double.tryParse(sensorData['nitrogen'] ?? '0') ?? 0;
    final phosphorus = double.tryParse(sensorData['phosphorus'] ?? '0') ?? 0;
    final potassium = double.tryParse(sensorData['potassium'] ?? '0') ?? 0;

    final nRatio = (nitrogen / 10).round();
    final pRatio = (phosphorus / 10).round();
    final kRatio = (potassium / 10).round();

    // --- Determine status ---
    bool isReady = nitrogen > 0 || phosphorus > 0 || potassium > 0;
    String statusText = '';
    String tipText = '';

    if (!isReady) {
      statusText = 'Insufficient compost';
      tipText = 'Fertilizer levels are too low to provide support for crops.';
    } else {
      statusText = 'Ready for Use';
      // Simple tips based on NPK ratio
      if (nRatio > pRatio && nRatio > kRatio) {
        tipText =
            'High nitrogen content: promotes leaf growth. Ideal for leafy vegetables.';
      } else if (pRatio > nRatio && pRatio > kRatio) {
        tipText =
            'High phosphorus content: promotes root development and flowering.';
      } else if (kRatio > nRatio && kRatio > pRatio) {
        tipText =
            'High potassium content: enhances fruit quality and resistance.';
      } else {
        tipText =
            'Balanced NPK ($nRatio:$pRatio:$kRatio) provides overall support for growth.';
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: shadowColor,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Text(
                  'Fertilizer Status',
                  style: GoogleFonts.interTight(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Icon(
                      isReady ? Icons.check_circle : Icons.error,
                      color: accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  tipText,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Text(
                  'How to Use',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  '• Apply during early growth and flowering stages.\n'
                  '• Dilute according to recommended dosage.\n'
                  '• Water soil before application to prevent root burn.\n'
                  '• Reapply every 10–14 days for best results.',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Text(
                  'Recommended Crops',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: fruits
                      .map(
                        (fruit) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: chipBgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            fruit,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
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
