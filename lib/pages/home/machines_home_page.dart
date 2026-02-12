import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nutribin_application/pages/home/register_machine_page.dart';
import 'package:nutribin_application/services/machine_service.dart';

class MachineSelectionPage extends StatefulWidget {
  const MachineSelectionPage({super.key});

  @override
  State<MachineSelectionPage> createState() => _MachineSelectionPageState();
}

class _MachineSelectionPageState extends State<MachineSelectionPage> {
  List<Map<String, dynamic>> existingMachines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMachineIds();
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
                            child: Text(
                              '${existingMachines.length} Active',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: highlightColor,
                              ),
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
                            serialNumber: machine['serial_number'] ?? 'Unknown',
                            machineId: machine['machine_id'] ?? '',
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
    required String serialNumber,
    required String machineId,
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
                    "serialNumber": serialNumber,
                    "machineId": machineId,
                  },
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: highlightColor.withOpacity(
                          isDarkMode ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.restore_from_trash,
                        size: 26,
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
                            serialNumber,
                            style: GoogleFonts.interTight(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            machineId,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: subTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Delete button
                    IconButton(
                      onPressed: () {
                        _showDeleteConfirmation(
                          serialNumber: serialNumber,
                          machineId: machineId,
                          highlightColor: highlightColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          isDarkMode: isDarkMode,
                        );
                      },
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.withOpacity(0.7),
                        size: 22,
                      ),
                      tooltip: 'Remove machine',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: subTextColor.withOpacity(0.5),
                      size: 24,
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
}
