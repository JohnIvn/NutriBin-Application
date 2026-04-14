import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nutribin_application/main.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nutribin_application/pages/home/register_machine_page.dart';
import 'package:nutribin_application/services/machine_service.dart';
import 'package:nutribin_application/services/announcement_service.dart';

// Helper function to format date strings
String _formatAnnouncementDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.toLocal().toString().split(' ')[0]}'; // Return date format
    }
  } catch (e) {
    return dateString; // Return original if parsing fails
  }
}

class MachineSelectionPage extends StatefulWidget {
  const MachineSelectionPage({super.key});

  @override
  State<MachineSelectionPage> createState() => _MachineSelectionPageState();
}

class _MachineSelectionPageState extends State<MachineSelectionPage> {
  List<Map<String, dynamic>> existingMachines = [];
  List<Map<String, dynamic>> announcements = [];
  DateTime? lastAnnouncementUpdate;
  bool isLoading = true;
  Timer? _machineRefreshTimer;

  @override
  void initState() {
    super.initState();
    fetchMachineIds();
    fetchAnnouncements();
    _startMachineRefresh();
  }

  @override
  void dispose() {
    _machineRefreshTimer?.cancel();
    super.dispose();
  }

  void _startMachineRefresh() {
    _machineRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && !isLoading) {
        fetchMachineIds();
      }
    });
  }

  void fetchMachineIds() async {
    try {
      final response = await MachineService.fetchExistingMachines();
      print("RESPONSE: ${response.toString()}");

      if (response['ok'] == true && response['data'] != null) {
        print("EXISTING MACHIENS: ${response['data']}");
        setState(() {
          existingMachines = List<Map<String, dynamic>>.from(response['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          existingMachines = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError(e.toString());
      print("FETCH ERROR: $e");
    }
  }

  void fetchAnnouncements() async {
    try {
      final response = await AnnouncementService.fetchAnnouncements();
      print("ANNOUNCEMENTS RESPONSE: $response");

      if (response['ok'] == true && response['data'] != null) {
        setState(() {
          // Handle both array and object responses
          final data = response['data'];
          print("ANNOUNCEMENTS DATA: $data");

          if (data is List) {
            print("Handling as List");
            announcements = List<Map<String, dynamic>>.from(data);
          } else if (data is Map) {
            // If the API returns announcements in a nested structure
            print("Handling as Map");
            final announcementList = data['announcements'] ?? [];
            print("ANNOUNCEMENT LIST: $announcementList");
            announcements = List<Map<String, dynamic>>.from(announcementList);
          }
          lastAnnouncementUpdate = DateTime.now();
          print("FINAL ANNOUNCEMENTS COUNT: ${announcements.length}");
        });
      } else {
        print("ERROR RESPONSE: ok=${response['ok']}, data=${response['data']}");
        // Still call setState to ensure UI updates even if fetch fails
        setState(() {
          announcements = [];
        });
      }
    } catch (e) {
      print("FETCH ANNOUNCEMENTS ERROR: $e");
      // Still call setState to ensure UI updates even on error
      setState(() {
        announcements = [];
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _showDeleteConfirmation({
    required String serialNumber,
    required String machineId,
    required Color highlightColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Remove Machine?',
                  style: GoogleFonts.interTight(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to remove this machine from your account?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: subTextColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serialNumber,
                      style: GoogleFonts.interTight(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      machineId,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.interTight(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Remove',
                style: GoogleFonts.interTight(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteMachine(machineId, serialNumber);
    }
  }

  void _showQRCode(
    String serialNumber,
    Color highlightColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1D2428) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Machine QR Code',
                            style: GoogleFonts.interTight(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            serialNumber,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: subTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: QrImageView(
                    data: serialNumber,
                    version: QrVersions.auto,
                    size: 220.0,
                    gapless: false,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Scan this code to register this machine on another device.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: highlightColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMachineOptions({
    required String serialNumber,
    required String machineId,
    required Color highlightColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              // View QR Option
              ListTile(
                leading: Icon(Icons.qr_code_rounded, color: highlightColor),
                title: Text(
                  'View QR Code',
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Scan to register on another device',
                  style: GoogleFonts.inter(fontSize: 12, color: subTextColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showQRCode(
                    serialNumber,
                    highlightColor,
                    textColor,
                    subTextColor,
                    isDarkMode,
                  );
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              // Delete Option
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: Text(
                  'Remove Machine',
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(
                  'Delete from your account',
                  style: GoogleFonts.inter(fontSize: 12, color: subTextColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(
                    serialNumber: serialNumber,
                    machineId: machineId,
                    highlightColor: highlightColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isDarkMode: isDarkMode,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteMachine(String machineId, String serialNumber) async {
    setState(() => isLoading = true);

    try {
      final deletionResponse = await MachineService.removeMachine(
        machineId: machineId,
      );

      if (deletionResponse["ok"] != true) {
        _showError(
          deletionResponse["message"] ??
              deletionResponse["error"] ??
              "Server failed to remove registered device",
        );
        return;
      }

      await Future.delayed(const Duration(seconds: 1));

      fetchMachineIds();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$serialNumber removed successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove machine: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- VISIBILITY COLORS ---
    final highlightColor = isDarkMode
        ? Theme.of(context).colorScheme.tertiary
        : primaryColor;

    // --- APP BAR COLORS ---
    final appBarBg = isDarkMode ? cardColor : primaryColor;
    const appBarTitleColor = Colors.white;
    const appBarSubtitleColor = Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.transparent, height: 1.0),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/Logo (Img).png', height: 42),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NutriBin',
                    style: GoogleFonts.interTight(
                      color: appBarTitleColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Machine Manager',
                    style: GoogleFonts.inter(
                      color: appBarSubtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: highlightColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Announcement Section
                    if (announcements.isNotEmpty)
                      _buildAnnouncementSection(
                        highlightColor: highlightColor,
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        isDarkMode: isDarkMode,
                      ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 8),
                      child: Row(
                        children: [
                          Text(
                            'Your Machines',
                            style: GoogleFonts.interTight(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: highlightColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${existingMachines.length} Registered',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: highlightColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 1,
                                  height: 12,
                                  color: highlightColor.withOpacity(0.3),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${existingMachines.where((m) => m['is_active'] == true).length} Online',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    // Machine List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: existingMachines.length + 1,
                      itemBuilder: (context, index) {
                        if (index == existingMachines.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAddMachineCard(
                              context,
                              highlightColor,
                              isDarkMode,
                            ),
                          );
                        }

                        final machine = existingMachines[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMachineCard(
                            context: context,
                            nickname:
                                (machine['nickname'] as String?) ??
                                machine['serial_number'] ??
                                'Unknown',
                            serialNumber: machine['serial_number'] ?? 'Unknown',
                            machineId: machine['machine_id'] ?? '',
                            isActive: machine['is_active'] ?? false,
                            highlightColor: highlightColor,
                            cardColor: cardColor,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            index: index,
                            isDarkMode: isDarkMode,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMachineCard({
    required BuildContext context,
    required String nickname,
    required String serialNumber,
    required String machineId,
    required bool isActive,
    required Color highlightColor,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required int index,
    required bool isDarkMode,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: isDarkMode
                ? Border.all(color: Colors.white.withOpacity(0.05))
                : null,
            boxShadow: isDarkMode
                ? []
                : [
                    const BoxShadow(
                      blurRadius: 4,
                      color: Color(0x1A000000),
                      offset: Offset(0, 2),
                    ),
                  ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/home',
                  arguments: {
                    "serialNumber": nickname.isNotEmpty
                        ? nickname
                        : serialNumber,
                    "machineId": machineId,
                    "isActive": isActive,
                  },
                );
              },
              onLongPress: () {
                debugPrint("LONG PRESS TRIGGERED FOR $serialNumber");
                HapticFeedback.vibrate();
                _showMachineOptions(
                  serialNumber: serialNumber,
                  machineId: machineId,
                  highlightColor: highlightColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDarkMode: isDarkMode,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: highlightColor.withOpacity(
                              isDarkMode ? 0.2 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.restore_from_trash,
                            size: 24,
                            color: highlightColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                nickname.isNotEmpty ? nickname : serialNumber,
                                style: GoogleFonts.interTight(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Online/Offline status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withOpacity(
                                    isDarkMode ? 0.2 : 0.1,
                                  )
                                : Colors.grey.withOpacity(
                                    isDarkMode ? 0.2 : 0.1,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'ONLINE' : 'OFFLINE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? (isDarkMode
                                            ? Colors.green[300]
                                            : Colors.green[700])
                                      : (isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: subTextColor.withOpacity(0.5),
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: ((index * 50).clamp(0, 500)).ms)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1));
  }

  Widget _buildAddMachineCard(
    BuildContext context,
    Color highlightColor,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: highlightColor.withOpacity(isDarkMode ? 0.05 : 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlightColor.withOpacity(0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterMachinePage(),
              ),
            );

            fetchMachineIds();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 24,
                  color: highlightColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Register New Machine',
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: highlightColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildAnnouncementSection({
    required Color highlightColor,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
  }) {
    // Empty state - show friendly message
    if (announcements.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Announcements Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Row(
              children: [
                Text(
                  'Announcements',
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          // Empty State Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF3F6B4B).withOpacity(0.5)
                  : const Color(0xFF2C3E2D).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.notifications_off_rounded,
                  size: 48,
                  color: isDarkMode ? Colors.white30 : Colors.black26,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Announcements',
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check back later for updates',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
        ],
      );
    }

    // Get the most important announcement to display as preview
    final announcement = announcements.first;
    final importance = (announcement['importance'] as String?) ?? 'Low';
    final title = (announcement['title'] as String?) ?? 'Announcement';
    final description = (announcement['description'] as String?) ?? '';
    final date = (announcement['date'] as String?) ?? '';

    Color importanceColor;
    Color importanceBgColor;
    IconData importanceIcon;

    switch (importance) {
      case 'High':
        importanceColor = const Color(0xFFD32F2F); // Error red
        importanceBgColor = const Color(
          0xFFD32F2F,
        ).withOpacity(0.28); // Error red background
        importanceIcon = Icons.warning_rounded;
        break;
      case 'Medium':
        importanceColor = Colors.orange;
        importanceBgColor = Colors.orange.withOpacity(0.1);
        importanceIcon = Icons.info_rounded;
        break;
      case 'Low':
      default:
        importanceColor = isDarkMode
            ? highlightColor
            : const Color.fromARGB(
                255,
                127,
                216,
                160,
              ); // Dark primary in dark mode, light green in light mode
        importanceBgColor =
            (isDarkMode
                    ? highlightColor
                    : const Color.fromARGB(255, 127, 216, 160))
                .withOpacity(0.15);
        importanceIcon = Icons.notifications_rounded;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Announcements Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Announcements',
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (lastAnnouncementUpdate != null)
                    Text(
                      'Updated ${_formatAnnouncementDate(lastAnnouncementUpdate.toString())}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: subTextColor.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: highlightColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          size: 14,
                          color: highlightColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${announcements.length}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: highlightColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
        // Announcement Preview Card
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showAllAnnouncements(
              highlightColor,
              cardColor,
              textColor,
              subTextColor,
              isDarkMode,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF36513D) // Dark green for dark mode
                  : const Color(0xFF2C3E2D), // Dark green container
              border: Border(
                left: BorderSide.none,
                top: isDarkMode
                    ? BorderSide(color: Colors.white.withOpacity(0.05))
                    : BorderSide.none,
                right: isDarkMode
                    ? BorderSide(color: Colors.white.withOpacity(0.05))
                    : BorderSide.none,
                bottom: isDarkMode
                    ? BorderSide(color: Colors.white.withOpacity(0.05))
                    : BorderSide.none,
              ),
              boxShadow: [],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: importanceBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        importanceIcon,
                        color: importanceColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.interTight(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors
                                        .white // White text in dark mode
                                  : const Color(
                                      0xFFFFFFFF,
                                    ), // White text on green
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: importanceBgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              importance,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: importanceColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.white70, // Light icon on green
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors
                              .white70 // White text in dark mode
                        : Colors.white70, // Light text on green
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.white70, // Light icon on green
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatAnnouncementDate(date),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.white70, // Light text on green
                          ),
                        ),
                      ],
                    ),
                    if (announcements.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A7856),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${announcements.length - 1} more',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }

  void _showAllAnnouncements(
    Color highlightColor,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDarkMode
              ? const Color(0xFF36513D) // Dark green for dark mode
              : const Color(0xFF2C3E2D), // Dark green container
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Announcements',
                        style: GoogleFonts.interTight(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? Colors
                                    .white // White text in dark mode
                              : Colors.white70, // White text on dark green
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? highlightColor.withOpacity(0.1)
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${announcements.length}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? highlightColor
                                  : Colors.white, // White text on dark green
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.1),
                height: 0,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      announcements.length,
                      (index) =>
                          _buildAnnouncementItem(
                                announcement: announcements[index],
                                highlightColor: highlightColor,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                isDarkMode: isDarkMode,
                                isLast: index == announcements.length - 1,
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                duration: 300.ms,
                                delay: (index * 50).ms,
                              ),
                    ),
                  ),
                ),
              ),
              Divider(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.1),
                height: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: highlightColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementItem({
    required Map<String, dynamic> announcement,
    required Color highlightColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
    required bool isLast,
  }) {
    final importance = (announcement['importance'] as String?) ?? 'Low';
    final title = (announcement['title'] as String?) ?? 'Announcement';
    final description = (announcement['description'] as String?) ?? '';
    final date = (announcement['date'] as String?) ?? '';

    Color importanceColor;
    Color importanceBgColor;
    IconData importanceIcon;

    switch (importance) {
      case 'High':
        importanceColor = const Color(
          0xFFE53935,
        ); // Material Red 600 - readable red
        importanceBgColor = const Color(0xFFE53935).withOpacity(0.1);
        importanceIcon = Icons.warning_rounded;
        break;
      case 'Medium':
        importanceColor = Colors.orange;
        importanceBgColor = Colors.orange.withOpacity(0.1);
        importanceIcon = Icons.info_rounded;
        break;
      case 'Low':
      default:
        importanceColor = const Color(0xFF7FD8A0); // Light green
        importanceBgColor = const Color(0xFF7FD8A0).withOpacity(0.15);
        importanceIcon = Icons.notifications_rounded;
        break;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: importanceBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      importanceIcon,
                      color: importanceColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.interTight(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors
                                      .white // White text in dark mode
                                : Colors.white, // White text on dark green
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: importanceBgColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            importance,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: importanceColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDarkMode
                      ? Colors
                            .white70 // White text in dark mode
                      : Colors.white70, // Light text on dark green
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: isDarkMode
                        ? Colors
                              .white70 // White text in dark mode
                        : Colors.white70, // Light text on dark green
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatAnnouncementDate(date),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.white70, // Light text on dark green
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.white.withOpacity(0.1),
            height: 0,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
