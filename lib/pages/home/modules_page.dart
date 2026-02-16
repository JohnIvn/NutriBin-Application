import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModulesPage extends StatefulWidget {
  final String machineId;
  const ModulesPage({super.key, required this.machineId});

  static String routeName = 'modules';
  static String routePath = '/modules';

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  bool isLoading = true;
  Map<String, dynamic> modulesData = {};

  @override
  void initState() {
    super.initState();
    _fetchModulesStatus();
  }

  // Color scheme
  Color get _primaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _cardColor =>
      Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _secondaryText =>
      Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;
  Color get _shadowColor => _isDarkMode
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.1);

  Future<void> _fetchModulesStatus() async {
    setState(() {
      isLoading = true;
    });

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - replace with actual API call when endpoint is ready
    setState(() {
      modulesData = {
        // Microcontrollers
        'c1': true, // Arduino Q
        'c2': true, // ESP32_Filter
        'c3': true, // ESP32_Servo_w_sensors
        'c4': true, // ESP32_Sensors
        // Sensors
        's1': true, // Camera
        's2': true, // Humidity
        's3': true, // Gas_Methane
        's4': false, // Gas_Carbon_monoxide (example offline)
        's5': true, // Gas_Air_quality
        's6': true, // Gas_Combustible_gassy
        's7': true, // NPK_Sensor
        's8': true, // Moisture
        's9': true, // Reed
        's10': true, // Ultrasonic
        's11': true, // Weight
        // Motors & Actuators
        'm1': true, // Servo_Lid_A
        'm2': true, // Servo_Lid_B
        'm3': true, // Servo_Mixer
        'm4': true, // Motor_Grinder
        'm5': false, // Exhaust_Fan_Out (example offline)
      };
      isLoading = false;
    });

    /* TODO: Replace with actual API call when endpoint is ready
    try {
      final response = await MachineService.fetchModulesStatus(
        machineId: widget.machineId,
      );

      if (response['ok'] == true && response['data'] != null) {
        setState(() {
          modulesData = Map<String, dynamic>.from(response['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError(e.toString());
    }
    */
  }

  Future<void> _restartMachine() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Restart Machine',
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to restart the NutriBin machine? This will temporarily halt all operations.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: _secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Restart',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Mock restart - replace with actual API call when endpoint is ready
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Machine restart initiated successfully (Mock)'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }

      /* TODO: Replace with actual API call when endpoint is ready
      try {
        final response = await MachineService.restartMachine(
          machineId: widget.machineId,
        );

        if (response['ok'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Machine restart initiated successfully'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          _showError('Failed to restart machine');
        }
      } catch (e) {
        _showError(e.toString());
      }
      */
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryBackground,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'System Modules',
          style: GoogleFonts.interTight(
            color: _textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.restart_alt, color: Colors.orange),
              tooltip: 'Restart Machine',
              onPressed: _restartMachine,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchModulesStatus,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Microcontrollers', Icons.memory),
                    const SizedBox(height: 12),
                    _buildModulesGrid([
                      ModuleInfo('C1', 'Arduino Q', modulesData['c1']),
                      ModuleInfo('C2', 'ESP32 Filter', modulesData['c2']),
                      ModuleInfo(
                        'C3',
                        'ESP32 Servo w/ Sensors',
                        modulesData['c3'],
                      ),
                      ModuleInfo('C4', 'ESP32 Sensors', modulesData['c4']),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectionHeader('Sensors', Icons.sensors),
                    const SizedBox(height: 12),
                    _buildModulesGrid([
                      ModuleInfo('S1', 'Camera', modulesData['s1']),
                      ModuleInfo('S2', 'Humidity', modulesData['s2']),
                      ModuleInfo('S3', 'Gas Methane', modulesData['s3']),
                      ModuleInfo(
                        'S4',
                        'Gas Carbon Monoxide',
                        modulesData['s4'],
                      ),
                      ModuleInfo('S5', 'Gas Air Quality', modulesData['s5']),
                      ModuleInfo('S6', 'Gas Combustible', modulesData['s6']),
                      ModuleInfo('S7', 'NPK Sensor', modulesData['s7']),
                      ModuleInfo('S8', 'Moisture', modulesData['s8']),
                      ModuleInfo('S9', 'Reed Switch', modulesData['s9']),
                      ModuleInfo('S10', 'Ultrasonic', modulesData['s10']),
                      ModuleInfo('S11', 'Weight Sensor', modulesData['s11']),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectionHeader(
                      'Motors & Actuators',
                      Icons.settings_input_component,
                    ),
                    const SizedBox(height: 12),
                    _buildModulesGrid([
                      ModuleInfo('M1', 'Servo Lid A', modulesData['m1']),
                      ModuleInfo('M2', 'Servo Lid B', modulesData['m2']),
                      ModuleInfo('M3', 'Servo Mixer', modulesData['m3']),
                      ModuleInfo('M4', 'Motor Grinder', modulesData['m4']),
                      ModuleInfo('M5', 'Exhaust Fan', modulesData['m5']),
                    ]),
                    const SizedBox(height: 12),
                    _buildStatusSummary(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.interTight(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildModulesGrid(List<ModuleInfo> modules) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        return _buildModuleCard(modules[index]);
      },
    );
  }

  Widget _buildModuleCard(ModuleInfo module) {
    final isOnline = module.status == true;
    final statusColor = isOnline ? Colors.green : Colors.red;
    final bgColor = isOnline
        ? (_isDarkMode ? Colors.green.withOpacity(0.1) : Colors.green.shade50)
        : (_isDarkMode ? Colors.red.withOpacity(0.1) : Colors.red.shade50);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    module.code,
                    style: GoogleFonts.interTight(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              module.name,
              style: GoogleFonts.inter(
                color: _textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isOnline ? Icons.check_circle : Icons.error,
                  color: statusColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummary() {
    // Count online and offline modules
    int totalModules = 0;
    int onlineModules = 0;

    modulesData.forEach((key, value) {
      if (key.startsWith('c') || key.startsWith('s') || key.startsWith('m')) {
        totalModules++;
        if (value == true) {
          onlineModules++;
        }
      }
    });

    final offlineModules = totalModules - onlineModules;
    final healthPercentage = totalModules > 0
        ? (onlineModules / totalModules * 100)
        : 0;

    Color healthColor;
    String healthStatus;
    if (healthPercentage >= 90) {
      healthColor = Colors.green;
      healthStatus = 'Excellent';
    } else if (healthPercentage >= 70) {
      healthColor = Colors.orange;
      healthStatus = 'Good';
    } else {
      healthColor = Colors.red;
      healthStatus = 'Needs Attention';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'System Health',
                style: GoogleFonts.interTight(
                  color: _textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Modules',
                  totalModules.toString(),
                  Colors.blue,
                  Icons.apps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Online',
                  onlineModules.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Offline',
                  offlineModules.toString(),
                  Colors.red,
                  Icons.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: healthColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: healthColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Status',
                      style: GoogleFonts.inter(
                        color: _secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      healthStatus,
                      style: GoogleFonts.interTight(
                        color: healthColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${healthPercentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.interTight(
                    color: healthColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.interTight(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(color: _secondaryText, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ModuleInfo {
  final String code;
  final String name;
  final bool? status;

  ModuleInfo(this.code, this.name, this.status);
}
