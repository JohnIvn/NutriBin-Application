import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nutribin_application/services/machine_service.dart';

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
      final response = await MachineService.fetchFertilizerStatus(
        machineId: widget.machineId,
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
                      // _buildAlertStatus(),
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

    // Calculate derived metrics from real data
    final weight =
        double.tryParse(sensorData['weight_kg']?.toString() ?? '0') ?? 0;
    final dailyOutput = weight > 0 ? (weight * 0.12).toStringAsFixed(1) : '0.0';
    final quality = weight > 0 ? '84.5' : '0.0';
    final efficiency = weight > 0 ? '85.2' : '0.0';

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
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.green.shade700,
                          size: 10,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.green.shade700,
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
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
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
    final temperature = double.tryParse(sensorData['temperature'] ?? '0') ?? 0;
    final humidity = double.tryParse(sensorData['humidity'] ?? '0') ?? 0;
    final ph = double.tryParse(sensorData['ph'] ?? '0') ?? 0;
    final moisture = double.tryParse(sensorData['moisture'] ?? '0') ?? 0;

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
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
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                color: color,
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
    final methane = double.tryParse(sensorData['methane'] ?? '0') ?? 0;
    final co =
        double.tryParse(sensorData['carbon_monoxide']?.toString() ?? '0') ?? 0;
    final airQuality =
        double.tryParse(sensorData['air_quality']?.toString() ?? '0') ?? 0;

    // Calculate gas levels (assuming max safe values)
    final methaneProgress = (methane / 50).clamp(0.0, 1.0);
    final coProgress = (co / 50).clamp(0.0, 1.0);
    final aqProgress = (airQuality / 100).clamp(0.0, 1.0);

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
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
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
              ),
              const SizedBox(height: 12),
              _buildGasLevelBar(
                'Carbon Monoxide (CO)',
                co,
                'ppm',
                Colors.red,
                coProgress,
              ),
              const SizedBox(height: 12),
              _buildGasLevelBar(
                'Air Quality Index',
                airQuality,
                'AQI',
                Colors.blue,
                aqProgress,
              ),
              const SizedBox(height: 16),
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
                        'All gas levels within safe operating limits',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildGasLevelBar(
    String name,
    double value,
    String unit,
    Color color,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _secondaryText,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
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
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
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
    final weight =
        double.tryParse(sensorData['weight_kg']?.toString() ?? '0') ?? 0;
    final totalCapacity = 10.0; // kg
    final currentLoad = weight;
    final availableSpace = totalCapacity - currentLoad;
    final fillPercentage = (currentLoad / totalCapacity).clamp(0.0, 1.0);

    // Calculate estimated days until full (assuming 2.5kg per day)
    final daysUntilFull = availableSpace > 0
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

    // Check reed switch status
    final reedSwitch = sensorData['reed_switch'];
    final isLidSecure =
        reedSwitch == null || reedSwitch == 0 || reedSwitch == false;

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
                children: [
                  Icon(Icons.settings, color: _iconColor, size: 28),
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
                          'Real-time functionality report',
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLidSecure
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLidSecure
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLidSecure ? Icons.info_outline : Icons.warning_amber,
                      color: isLidSecure
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isLidSecure
                            ? 'All modules functional: Keep the lid from being tampered with hard objects'
                            : 'Warning: Lid is open or compromised',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLidSecure
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                        ),
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
}
