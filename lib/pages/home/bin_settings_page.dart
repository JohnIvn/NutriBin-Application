import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/services/machine_service.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class BinSettingsPage extends StatefulWidget {
  final String machineId;
  const BinSettingsPage({super.key, required this.machineId});

  @override
  State<BinSettingsPage> createState() => _BinSettingsPageState();
}

class _BinSettingsPageState extends State<BinSettingsPage> {
  bool _isLoading = false;
  String _serialNumber = "";
  String _firmware = "Loading...";
  String _model = "Loading...";
  bool _isUpdateAvailable = false;
  bool _isOnline = false;
  String? _latestVersion;
  String? _targetVersion;
  String _updateStatus = "none";
  double _updateProgress = 0.0;
  List<Map<String, dynamic>> _availableFirmwareVersions = [];
  final TextEditingController _nicknameController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadBinSettings();
    _checkUpdate();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _checkUpdate() async {
    try {
      final response = await MachineService.checkFirmwareUpdate(
        machineId: widget.machineId,
      );
      if (response['ok'] == true) {
        if (mounted) {
          setState(() {
            _isOnline = response['isOnline'] ?? false;
            _updateStatus = response['updateStatus'] ?? "none";
            _updateProgress =
                double.tryParse(response['updateProgress']?.toString() ?? '0') ??
                    0.0;
            _isUpdateAvailable = response['updateAvailable'] == true;
            _latestVersion = response['latestVersion'];
            _targetVersion = response['targetFirmwareVersion'];
          });
        }
      }
    } catch (e) {
      print("Update check failed: $e");
    }
  }

  Future<void> _loadFirmwareVersions() async {
    try {
      final response = await MachineService.getFirmwareVersions(
        machineId: widget.machineId,
      );
      if (response['ok'] == true && response['versions'] != null) {
        if (mounted) {
          setState(() {
            _availableFirmwareVersions =
                List<Map<String, dynamic>>.from(response['versions'] ?? []);
          });
        }
      }
    } catch (e) {
      print("Failed to load firmware versions: $e");
    }
  }

  Future<void> _showDowngradeDialog() async {
    if (_availableFirmwareVersions.isEmpty) {
      await _loadFirmwareVersions();
    }

    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline device - Cannot downgrade. Please check connection.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_availableFirmwareVersions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No firmware versions available for downgrade'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String? selectedVersion;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final theme = Theme.of(context);
          final primaryColor = theme.primaryColor;
          
          return AlertDialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: theme.dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Restore Firmware',
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a previous stable version to restore your machine state.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _availableFirmwareVersions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final version = _availableFirmwareVersions[index];
                        final versionString = version['version'] ?? 'Unknown';
                        final isCurrentVersion = versionString == _firmware;
                        final isSelected = selectedVersion == versionString;

                        return InkWell(
                          onTap: isCurrentVersion
                              ? null
                              : () => setDialogState(() => selectedVersion = versionString),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange.withOpacity(0.1)
                                  : (isCurrentVersion 
                                      ? theme.cardColor.withOpacity(0.5) 
                                      : theme.cardColor),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : (isCurrentVersion
                                        ? Colors.transparent
                                        : theme.dividerColor.withOpacity(0.1)),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            versionString,
                                            style: GoogleFonts.firaCode(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: isCurrentVersion
                                                  ? theme.colorScheme.onSurface.withOpacity(0.3)
                                                  : theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          if (isCurrentVersion) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'CURRENT',
                                                style: GoogleFonts.inter(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        version['releaseDate'] != null
                                            ? 'Released ${DateTime.parse(version['releaseDate']).toLocal().toString().split(' ')[0]}'
                                            : 'Unknown release date',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isCurrentVersion)
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected
                                        ? Colors.orange
                                        : theme.colorScheme.onSurface.withOpacity(0.2),
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Dismiss',
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedVersion != null && selectedVersion != _firmware
                          ? () {
                              Navigator.pop(context);
                              _proceedWithDowngrade(selectedVersion!);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: theme.dividerColor.withOpacity(0.1),
                        disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      child: Text(
                        'Restore',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _proceedWithDowngrade(String selectedVersion) async {
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Downgrade',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        content: Text(
          'Are you sure you want to downgrade to version $selectedVersion? This action cannot be undone easily.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm Downgrade', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (proceed == true) {
      _startDowngradeProcess(selectedVersion);
    }
  }

  Future<void> _startDowngradeProcess(String version) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.orange),
                const SizedBox(height: 20),
                Text(
                  'Initiating Firmware Downgrade...',
                  style: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Communicating with server...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    final response = await MachineService.updateFirmware(
      machineId: widget.machineId,
      version: version,
    );

    if (mounted) {
      Navigator.pop(context); // Close initiating dialog

      if (response['ok'] == true) {
        _simulateUpdate(version);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Downgrade initiation failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showUpdateDialog() async {
    if ((_latestVersion == null || !_isUpdateAvailable) &&
        (_updateStatus != "failed" && _updateStatus != "interrupted")) {
      return;
    }

    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline device - Cannot update. Please check connection.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Firmware Update Available',
          style: GoogleFonts.interTight(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'A new version ($_latestVersion) is available for your model. Would you like to update now?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Later', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: Text('Update Now', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (proceed == true) {
      _startUpdateProcess(_latestVersion!);
    }
  }

  Future<void> _startUpdateProcess(String version) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF2E7D32)),
                const SizedBox(height: 20),
                Text(
                  'Initiating Firmware Update...',
                  style: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Communicating with server...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Initial call to move status to pending
    final response = await MachineService.updateFirmware(
      machineId: widget.machineId,
      version: version,
    );

    if (mounted) {
      Navigator.pop(context); // Close initiating dialog

      if (response['ok'] == true) {
        // Start 10-second simulation
        _simulateUpdate(version);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Initiation failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _simulateUpdate(String version) async {
    // Reset progress to 0
    setState(() {
      _updateProgress = 0.0;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              content: StreamBuilder<double>(
                stream: Stream.periodic(const Duration(milliseconds: 500), (_) => _updateProgress),
                builder: (context, snapshot) {
                  final progress = _updateProgress;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: progress / 100,
                              strokeWidth: 8,
                              color: const Color(0xFF2E7D32),
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                          Text(
                            '${progress.toInt()}%',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Updating...',
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please do not turn off the machine.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          );
        },
      ),
    );

    // Simulate 10 seconds with 10% per second
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Call backend to update progress
        await MachineService.updateProgress(
          machineId: widget.machineId,
          updateProgress: (i * 10).toString(),
        );

        setState(() {
          _updateProgress = (i * 10).toDouble();
          _updateStatus = 'pending';
        });
      }
    }

    // After 10 seconds, complete the update on backend
    if (mounted) {
      await MachineService.completeUpdate(
        machineId: widget.machineId,
      );

      setState(() {
        _updateStatus = 'success';
        _firmware = version;
        _isUpdateAvailable = false;
      });

      Navigator.pop(context); // Close progress dialog
      _loadBinSettings(); // Refresh firmware version
      _checkUpdate(); // Refresh update status

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firmware updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadBinSettings() async {
    setState(() => _isLoading = true);
    try {
      final response = await MachineService.fetchBinSettings(
        machineId: widget.machineId,
      );
      if (response['ok'] == true && response['data'] != null) {
        if (mounted) {
          setState(() {
            _nicknameController.text = response['data']['nickname'] ?? "";
            _serialNumber =
                response['data']['serial_number'] ?? widget.machineId;
            _firmware = response['data']['firmware_version'] ?? "Unknown";
            _model = response['data']['model'] ?? "NutriBin v1";
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNickname(String value) async {
    final response = await MachineService.updateBinNickname(
      machineId: widget.machineId,
      nickname: value,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Nickname updated'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _unlinkDevice() async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unlink Device',
          style: GoogleFonts.interTight(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to unlink this device? You will need to scan the QR code to add it again.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Unlink',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final response = await MachineService.removeMachine(
        machineId: widget.machineId,
      );

      if (mounted) {
        if (response['ok'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device unlinked successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to machines home or refresh
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to unlink device'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveQRToGallery() async {
    try {
      // Check permissions based on platform/version
      bool hasPermission = false;

      if (Platform.isAndroid) {
        // For Android 13+ (API 33), we need Photos permission
        // For older versions, we need Storage permission
        if (await Permission.photos.request().isGranted ||
            await Permission.storage.request().isGranted) {
          hasPermission = true;
        }
      } else {
        // iOS
        hasPermission = await Gal.hasAccess();
        if (!hasPermission) {
          hasPermission = await Gal.requestAccess();
        }
      }

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Photo Gallery permission is required to save the QR code',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: openAppSettings,
              ),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saving QR code...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Capture the QR as an image natively using the screenshot controller
      final imageBytes = await _screenshotController.captureFromWidget(
        Material(
          child: Container(
            padding: const EdgeInsets.all(40),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NutriBin: ${_nicknameController.text}',
                  style: GoogleFonts.interTight(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Scan to register this machine',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                QrImageView(
                  data: _serialNumber,
                  version: QrVersions.auto,
                  size: 400.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 30),
                Text(
                  'SERIAL: $_serialNumber',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/QR_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(imageBytes);

      await Gal.putImage(path, album: 'NutriBin');

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code saved to gallery'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        // Exit modal immediately after saving
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving QR: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showShareQR() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Share ${_nicknameController.text}',
                style: GoogleFonts.interTight(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan this code to link this bin to another account',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Hero(
                  tag: 'qr-code-$_serialNumber',
                  child: QrImageView(
                    data: _serialNumber,
                    version: QrVersions.auto,
                    size: 220.0,
                    gapless: false,
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _serialNumber,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1.1,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _serialNumber));
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Serial ID copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        // Exit modal immediately
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy ID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveQRToGallery,
                      icon: const Icon(Icons.save_alt_rounded, size: 18),
                      label: const Text('Save Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Bin Settings',
                      style: GoogleFonts.interTight(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 16,
                      bottom: 16,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Operational Mode'),
                        _buildModernTile(
                          title: 'Bin Nickname',
                          subtitle: 'Personalize your device name',
                          icon: Icons.edit_note_rounded,
                          trailing: SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _nicknameController,
                              style: GoogleFonts.inter(fontSize: 14),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Nickname',
                              ),
                              textAlign: TextAlign.end,
                              onSubmitted: (value) => _updateNickname(value),
                            ),
                          ),
                        ),
                        _buildModernTile(
                          title: 'Share Bin',
                          subtitle: 'Generate QR for others to link',
                          icon: Icons.qr_code_2_rounded,
                          onTap: () => _showShareQR(),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Hardware & Updates'),
                        _buildModernTile(
                          title: 'Firmware Update',
                          subtitle: !_isOnline && (_isUpdateAvailable || _updateStatus == "failed" || _updateStatus == "interrupted" || _updateStatus == "pending")
                              ? 'Offline device - Cannot update'
                              : (_updateStatus == "failed"
                                  ? 'Update failed at ${_updateProgress.toInt()}%'
                                  : (_updateStatus == "interrupted"
                                      ? 'Update interrupted at ${_updateProgress.toInt()}%'
                                      : (_updateStatus == "pending"
                                          ? 'Update in progress: ${_updateProgress.toInt()}%'
                                          : (_isUpdateAvailable
                                              ? 'New version $_latestVersion available'
                                              : 'Your firmware is up to date')))),
                          icon: Icons.system_update_rounded,
                          onTap: (_isUpdateAvailable ||
                              _updateStatus == "failed" ||
                              _updateStatus == "interrupted") && 
                              _updateStatus != "pending" && 
                              _isOnline
                              ? _showUpdateDialog
                              : null,
                          trailing: _updateStatus == "failed"
                              ? const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red,
                                  size: 20,
                                )
                              : (_updateStatus == "interrupted"
                                    ? const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                        size: 20,
                                      )
                                    : (_updateStatus == "pending"
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF2E7D32),
                                              ),
                                            )
                                          : (_isUpdateAvailable
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .orange
                                                          .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'UPDATE',
                                                      style: GoogleFonts.inter(
                                                        color: Colors
                                                            .orange
                                                            .shade900,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .check_circle_outline_rounded,
                                                    color: Colors.green,
                                                    size: 20,
                                                  )))),
                        ),
                        _buildModernTile(
                          title: 'Downgrade Firmware',
                          subtitle: _updateStatus == "pending"
                              ? 'Update in progress: ${_updateProgress.toInt()}%'
                              : (!_isOnline
                                  ? 'Offline device - Cannot downgrade'
                                  : 'Select a previous firmware version'),
                          icon: Icons.download_for_offline_rounded,
                          onTap: _isOnline && _updateStatus != "pending"
                              ? _showDowngradeDialog
                              : null,
                          trailing: _updateStatus == "pending"
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF2E7D32),
                                  ),
                                )
                              : const Icon(Icons.chevron_right_rounded),
                        ),
                        _buildModernTile(
                          title: 'Restart Machine',
                          subtitle: 'Reboot the NutriBin controller',
                          icon: Icons.restart_alt_rounded,
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Restart Machine',
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                  'Are you sure you want to restart the machine?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Restart',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final res = await MachineService.restartMachine();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message']),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          trailing: const Icon(
                            Icons.power_settings_new_rounded,
                          ),
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Device Details'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'Serial Number',
                                _serialNumber,
                                Icons.qr_code_2_rounded,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Machine ID',
                                widget.machineId,
                                Icons.fingerprint_rounded,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Firmware',
                                _firmware,
                                Icons.system_update_rounded,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Model',
                                _model,
                                Icons.category_rounded,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _unlinkDevice,
                            icon: const Icon(
                              Icons.link_off_rounded,
                              color: Colors.redAccent,
                            ),
                            label: Text(
                              'Unlink Device',
                              style: GoogleFonts.inter(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Space for navbar
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).primaryColor.withOpacity(0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildModernTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: theme.primaryColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.firaCode(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
