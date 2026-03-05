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
  final TextEditingController _nicknameController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadBinSettings();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
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
            _serialNumber = response['data']['serial_number'] ?? widget.machineId;
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
              content: Text('Photo Gallery permission is required to save the QR code'),
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
      final path = '${tempDir.path}/QR_${DateTime.now().millisecondsSinceEpoch}.png';
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                Icons.fingerprint,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Firmware',
                                'v1.0.4 - Stable',
                                Icons.system_update_rounded,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Signal Strength',
                                'Excellent',
                                Icons.wifi_tethering_rounded,
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
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
