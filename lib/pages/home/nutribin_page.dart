import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nutribin_application/services/machine_service.dart';
import 'package:nutribin_application/pages/home/modules_page.dart';

class NutriBinPage extends StatefulWidget {
  final String machineId;
  const NutriBinPage({super.key, required this.machineId});

  @override
  State<NutriBinPage> createState() => _NutriBinPageState();
}

class _NutriBinPageState extends State<NutriBinPage> {
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

  // Modules Data for alert
  Map<String, dynamic> modulesData = {};

  // Color scheme
  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _cardColor =>
      Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _secondaryText =>
      Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;
  Color get _iconColor => _isDarkMode ? Colors.white : _primaryColor;

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
      final results = await Future.wait([
        MachineService.fetchFertilizerStatus(machineId: widget.machineId),
        MachineService.fetchModulesStatus(machineId: widget.machineId),
      ]);

      final sensorResponse = results[0];
      final modulesResponse = results[1];

      if (mounted) {
        setState(() {
          if (sensorResponse['ok'] == true && sensorResponse['data'] != null) {
            sensorData = Map<String, dynamic>.from(sensorResponse['data']);
          }
          if (modulesResponse['ok'] == true &&
              modulesResponse['data'] != null) {
            modulesData = Map<String, dynamic>.from(modulesResponse['data']);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
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
                      _buildAlertStatus(),
                      _buildCapacityTracking(),
                      _buildStatusOverview(),
                      _buildNutriBinCondition(),
                      _buildGasDetection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatusOverview() {
    final shadowColor = _isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    final isMachineOffline = sensorData['is_active'] == false;

    final weightRaw = sensorData['weight_kg'];
    final weight = (weightRaw == null || weightRaw == 'offline')
        ? 0.0
        : (double.tryParse(weightRaw.toString()) ?? 0.0);

    final dailyOutput = weight > 0 ? (weight * 0.12).toStringAsFixed(1) : '0.0';
    final quality = weight > 0 ? '84.5' : '0.0';
    final efficiency = weight > 0 ? '85.2' : '0.0';

    // Badge properties driven by machine state
    final badgeColor = isMachineOffline ? Colors.grey : Colors.green;
    final badgeLabel = isMachineOffline ? 'OFFLINE' : 'ACTIVE';
    final badgeIcon = isMachineOffline ? Icons.circle_outlined : Icons.circle;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _cardColor,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Production Status',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(badgeIcon, color: badgeColor, size: 10),
                        const SizedBox(width: 6),
                        Text(
                          badgeLabel,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStat(
                      'Daily Output',
                      '$dailyOutput kg',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildQuickStat(
                      'Quality',
                      '$quality%',
                      Icons.verified,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStat(
                      'Efficiency',
                      '$efficiency%',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildQuickStat(
                      'Batches',
                      '2',
                      Icons.layers,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isMachineOffline = sensorData['is_active'] == false;
    final displayValue = isMachineOffline ? '--' : value;
    final displayColor = isMachineOffline ? Colors.grey : color;

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: displayColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: displayColor, size: 28),
          const SizedBox(height: 8),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: displayColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: _secondaryText)),
        ],
      ),
    );
  }

  Widget _buildNutriBinCondition() {
    final shadowColor = _isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    // Parse sensor values
    double parseVal(dynamic val) {
      if (val == null || val == 'offline') return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final temperature = parseVal(sensorData['temperature']);
    final humidity = parseVal(sensorData['humidity']);
    final ph = parseVal(sensorData['ph']);
    final moisture = parseVal(sensorData['moisture']);

    final isMachineOffline = sensorData['is_active'] == false;
    if (isMachineOffline) return const SizedBox.shrink();

    // Determine status based on values
    String getTempStatus(double temp) {
      if (temp >= 15 && temp <= 25) return 'Optimal';
      if (temp >= 10 && temp <= 30) return 'Good';
      return 'Warning';
    }

    String getHumidityStatus(double hum) {
      if (hum >= 60 && hum <= 80) return 'Good';
      if (hum >= 50 && hum <= 90) return 'Fair';
      return 'Warning';
    }

    String getPhStatus(double phValue) {
      if (phValue >= 6.5 && phValue <= 7.5) return 'Neutral';
      if (phValue >= 6.0 && phValue <= 8.0) return 'Acceptable';
      return 'Warning';
    }

    String getMoistureStatus(double moist) {
      if (moist >= 40 && moist <= 60) return 'Normal';
      if (moist >= 30 && moist <= 70) return 'Fair';
      return 'Warning';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _cardColor,
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
                  Icon(Icons.wb_sunny, color: _iconColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NutriBin Condition',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Temperature & humidity tracking',
                          style: TextStyle(
                            color: _secondaryText.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildEnvironmentCard(
                      'Temperature',
                      '${temperature.toStringAsFixed(1)}°C',
                      Icons.thermostat,
                      Colors.red,
                      getTempStatus(temperature),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnvironmentCard(
                      'Humidity',
                      '${humidity.toStringAsFixed(1)}%',
                      Icons.water_drop,
                      Colors.blue,
                      getHumidityStatus(humidity),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEnvironmentCard(
                      'pH Level',
                      ph.toStringAsFixed(1),
                      Icons.science,
                      Colors.green,
                      getPhStatus(ph),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnvironmentCard(
                      'Moisture',
                      '${moisture.toStringAsFixed(1)}%',
                      Icons.opacity,
                      Colors.teal,
                      getMoistureStatus(moisture),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String status,
  ) {
    final isMachineOffline = sensorData['is_active'] == false;
    final displayValue = isMachineOffline ? '0.0' : value;
    final displayStatus = isMachineOffline ? 'Offline' : status;
    final displayColor = isMachineOffline ? Colors.grey : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: displayColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: displayColor, size: 32),
          const SizedBox(height: 10),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: displayColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: _secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: displayColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayStatus,
              style: TextStyle(
                fontSize: 11,
                color: displayColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGasDetection() {
    final shadowColor = _isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    // Parse gas sensor values
    double parseGas(dynamic val) {
      if (val == null || val == 'offline') return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final methane = parseGas(sensorData['methane']);
    final co = parseGas(sensorData['carbon_monoxide']);
    final airQuality = parseGas(sensorData['air_quality']);

    // If all zero (offline/no data) or isMachineOffline, decide if we hide
    final isMachineOffline = sensorData['is_active'] == false;
    final bool allZero = methane == 0 && co == 0 && airQuality == 0;

    if (isMachineOffline || allZero) return const SizedBox.shrink();

    // Progress bars (max raw ADC = 4095)
    final methaneProgress = (methane / 4095).clamp(0.0, 1.0);
    final coProgress = (co / 4095).clamp(0.0, 1.0);
    final aqProgress = (airQuality / 4095).clamp(0.0, 1.0);

    // Danger thresholds — flag if any reading hits 4095
    final bool methaneDanger = methane >= 4095;
    final bool coDanger = co >= 4095;
    final bool aqDanger = airQuality >= 4095;
    final bool anyDanger = methaneDanger || coDanger || aqDanger;

    // Status badge
    final badgeColor = anyDanger ? Colors.red : Colors.green;
    final badgeIcon = anyDanger
        ? Icons.warning_amber_rounded
        : Icons.check_circle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _cardColor,
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.air, color: _iconColor, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gas Detection',
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Monitoring harmful gases',
                            style: TextStyle(
                              color: _secondaryText.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(badgeIcon, color: badgeColor, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildGasLevelBar(
                'Methane (CH₄)',
                methane,
                'ppm',
                Colors.orange,
                methaneProgress,
                methaneDanger,
              ),
              const SizedBox(height: 12),
              _buildGasLevelBar(
                'Carbon Monoxide (CO)',
                co,
                'ppm',
                Colors.red,
                coProgress,
                coDanger,
              ),
              const SizedBox(height: 12),
              _buildGasLevelBar(
                'Air Quality Index',
                airQuality,
                'AQI',
                Colors.blue,
                aqProgress,
                aqDanger,
              ),

              // Only show status banner when there's a concern
              if (anyDanger) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'High gas levels detected! Ventilate the area and inspect the machine immediately.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGasLevelBar(
    String name,
    double value,
    String unit,
    Color color,
    double progress,
    bool isDanger,
  ) {
    final isMachineOffline = sensorData['is_active'] == false;
    final displayColor = isMachineOffline
        ? Colors.grey
        : (isDanger ? Colors.red : color);
    final displayProgress = isMachineOffline ? 0.0 : progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _secondaryText,
                  ),
                ),
                if (isDanger) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 14,
                  ),
                ],
              ],
            ),
            Text(
              isMachineOffline
                  ? '0.0 $unit'
                  : '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: displayColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: displayProgress,
            child: Container(
              decoration: BoxDecoration(
                color: displayColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityTracking() {
    final shadowColor = _isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    // Parse weight data
    final isMachineOffline = sensorData['is_active'] == false;
    final weightRaw = isMachineOffline ? '0' : sensorData['weight_kg'];
    final weight = double.tryParse(weightRaw?.toString() ?? '0') ?? 0;
    final totalCapacity = 10.0; // kg
    final currentLoad = weight;
    final availableSpace = (totalCapacity - currentLoad).clamp(
      0.0,
      totalCapacity,
    );
    final fillPercentage = (currentLoad / totalCapacity).clamp(0.0, 1.0);

    // Calculate estimated days until full (assuming 2.5kg per day)
    final daysUntilFull = (availableSpace > 0 && !isMachineOffline)
        ? (availableSpace / 2.5).toStringAsFixed(1)
        : '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _cardColor,
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
                  Icon(Icons.storage, color: _iconColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capacity & Storage',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Current chamber utilization',
                          style: TextStyle(
                            color: _secondaryText.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: fillPercentage,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                                strokeWidth: 12,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${(fillPercentage * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Filled',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Main Chamber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCapacityDetail(
                          'Total Capacity',
                          '${totalCapacity.toStringAsFixed(1)} kg',
                        ),
                        const SizedBox(height: 12),
                        _buildCapacityDetail(
                          'Current Load',
                          '${currentLoad.toStringAsFixed(1)} kg',
                        ),
                        const SizedBox(height: 12),
                        _buildCapacityDetail(
                          'Available Space',
                          '${availableSpace.toStringAsFixed(1)} kg',
                        ),
                        const SizedBox(height: 12),
                        _buildCapacityDetail(
                          'Est. Full',
                          '$daysUntilFull days',
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
    );
  }

  Widget _buildCapacityDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: _secondaryText)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertStatus() {
    final shadowColor = _isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    // Collect faulted modules from modulesData
    final List<String> faultedModules = [];
    const moduleLabels = {
      'c1': 'Arduino Q (C1)',
      'c2': 'ESP32 Filter (C2)',
      'c3': 'ESP32 Servo w/ Sensors (C3)',
      'c4': 'ESP32 Sensors (C4)',
      's1': 'Camera (S1)',
      's2': 'Humidity (S2)',
      's3': 'Gas Methane (S3)',
      's4': 'Gas Carbon Monoxide (S4)',
      's5': 'Gas Air Quality (S5)',
      's6': 'Gas Combustible (S6)',
      's7': 'NPK Sensor (S7)',
      's8': 'Moisture (S8)',
      's9': 'Reed Switch (S9)',
      's10': 'Ultrasonic (S10)',
      's11': 'Weight Sensor (S11)',
      'm1': 'Servo Lid A (M1)',
      'm2': 'Servo Lid B (M2)',
      'm3': 'Servo Mixer (M3)',
      'm4': 'Motor Grinder (M4)',
      'm5': 'Exhaust Fan (M5)',
    };

    modulesData.forEach((key, value) {
      if (moduleLabels.containsKey(key)) {
        // A module ONLY requires attention if it is explicitly marked as "broken"
        // in the data, regardless of whether the machine is currently offline or not.
        // We check for false (from boolean mapping) or "offline & broken" (from strings).
        if (value == false || value == 'offline & broken') {
          faultedModules.add(moduleLabels[key]!);
        }
      }
    });

    final isMachineOffline = sensorData['is_active'] == false;
    final bool hasModuleFaults = faultedModules.isNotEmpty;

    // If machine is offline, we only show the faults banner if there are
    // actually broken parts in the latest data, but we don't count everything
    // as "requiring attention" just because it's offline.
    // The previous logic already checks `value != true` which covers 'offline' strings
    // and false booleans.

    final displayedModules = faultedModules.take(5).toList();
    final extraCount = faultedModules.length - displayedModules.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _cardColor,
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
              // Header
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ModulesPage(machineId: widget.machineId),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: _iconColor,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NutriBin Machine Status',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isMachineOffline
                              ? 'Machine is currently OFFLINE'
                              : 'Real-time functionality report',
                          style: TextStyle(
                            color: isMachineOffline
                                ? Colors.red.withOpacity(0.8)
                                : _secondaryText.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: isMachineOffline
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Static care tips — tap to reveal tooltip
              Tooltip(
                message:
                    '• Keep away from water and rain\n'
                    '• Avoid prolonged direct sunlight\n'
                    '• Do not place heavy objects on top\n'
                    '• Keep lid free from hard impacts\n'
                    '• Ensure ventilation around the unit',
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Keep the machine in a dry, ventilated area away from direct sunlight.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.touch_app,
                        color: Colors.blue.shade400,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Module faults
              if (hasModuleFaults) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${faultedModules.length} module${faultedModules.length > 1 ? 's' : ''} require attention',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...displayedModules.map(
                        (module) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                module,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (extraCount > 0) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ModulesPage(machineId: widget.machineId),
                            ),
                          ),
                          child: Text(
                            '+$extraCount more...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ModulesPage(machineId: widget.machineId),
                          ),
                        ),
                        child: Text(
                          'Tap to view modules & request repair →',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // All clear
              if (!hasModuleFaults) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'All modules are online and functioning normally',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
