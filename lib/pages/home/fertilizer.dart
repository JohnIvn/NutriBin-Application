import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/services/machine_service.dart';

class FertilizerPage extends StatefulWidget {
  final String machineId;
  const FertilizerPage({super.key, required this.machineId});

  @override
  State<FertilizerPage> createState() => _FertilizerPageState();
}

class _FertilizerPageState extends State<FertilizerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _dataRefreshTimer;

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

  List<Map<String, dynamic>> recommendedCrops = [];

  // Color scheme
  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startDataRefresh();
  }

  @override
  void dispose() {
    _dataRefreshTimer?.cancel();
    super.dispose();
  }

  void _startDataRefresh() {
    // Refresh data every 5 seconds
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final response = await MachineService.fetchFertilizerStatus(
        machineId: widget.machineId,
      );

      final recommendationsResponse =
          await MachineService.fetchRecommendedCrops(
            machineId: widget.machineId,
          );

      if (mounted) {
        setState(() {
          if (response['ok'] == true && response['data'] != null) {
            sensorData = Map<String, dynamic>.from(response['data']);
          }
          if (recommendationsResponse['ok'] == true) {
            recommendedCrops = List<Map<String, dynamic>>.from(
              recommendationsResponse['recommendations'],
            );
          }
          isLoading = false;
        });
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

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _secondaryBackground,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: _primaryColor))
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _fertilizerStatusCard(),
                      _buildNPKMonitoring(),
                      const SizedBox(height: 20),
                    ],
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

    final List<Map<String, dynamic>> displayedCrops =
        recommendedCrops.isNotEmpty
        ? recommendedCrops
        : [
            {'name': 'Tomato', 'score': null},
            {'name': 'Cucumber', 'score': null},
            {'name': 'Bell Pepper', 'score': null},
            {'name': 'Strawberry', 'score': null},
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recommended Crops',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    if (recommendedCrops.isNotEmpty)
                      const Icon(
                        Icons.cloud_done,
                        size: 14,
                        color: Colors.green,
                      )
                    else
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.orange,
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: displayedCrops
                      .map(
                        (crop) => InkWell(
                          onTap: () {
                            if (crop['score'] != null) {
                              _showCropScore(crop['name'], crop['score']);
                            } else {
                              _showError(
                                "No CSI score available for this crop yet.",
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: chipBgColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              crop['name'],
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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

  void _showCropScore(String name, dynamic score) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '$name Suitability',
          style: GoogleFonts.interTight(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Crop Suitability Index (CSI)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: (score as num) / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      score > 70
                          ? Colors.green
                          : score > 40
                          ? Colors.orange
                          : Colors.red,
                    ),
                    strokeWidth: 10,
                  ),
                ),
                Text(
                  '$score%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreDescription(score as int),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getScoreDescription(int score) {
    if (score > 80) return 'Highly recommended! Soil conditions are ideal.';
    if (score > 60) return 'Recommended. Conditions are favorable for growth.';
    if (score > 40) return 'Moderately suitable. May require some adjustments.';
    return 'Low compatibility. Soil nutrients are not optimal for this crop.';
  }

  Widget _buildNPKMonitoring() {
    // --- DYNAMIC COLORS ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);
    final infoBgColor = isDarkMode
        ? Colors.blue.shade900.withOpacity(0.2)
        : Colors.blue.shade50;
    final infoBorderColor = isDarkMode
        ? Colors.blue.shade400.withOpacity(0.3)
        : Colors.blue.shade200;
    final infoTextColor = isDarkMode
        ? Colors.blue.shade200
        : Colors.blue.shade900;

    // Parse sensor values
    final nitrogen = double.tryParse(sensorData['nitrogen'] ?? '0') ?? 0;
    final phosphorus = double.tryParse(sensorData['phosphorus'] ?? '0') ?? 0;
    final potassium = double.tryParse(sensorData['potassium'] ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science, color: textColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NPK Nutrient Levels',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Real-time nutrient monitoring',
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNPKGauge('Nitrogen', nitrogen, Colors.blue),
                  _buildNPKGauge('Phosphorus', phosphorus, Colors.orange),
                  _buildNPKGauge('Potassium', potassium, Colors.green),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: infoBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: infoBorderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: infoTextColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Optimal NPK ratio: 3:1:2 - Current levels are balanced',
                        style: TextStyle(fontSize: 12, color: infoTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNPKGauge(String label, double value, Color color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.shade100;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    // Calculate percentage (assuming max value of 200 ppm)
    final percentage = (value / 200).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: percentage,
                backgroundColor: bgColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 10,
              ),
            ),
            Column(
              children: [
                Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'ppm',
                  style: TextStyle(fontSize: 11, color: subTextColor),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: subTextColor,
          ),
        ),
      ],
    );
  }
}
