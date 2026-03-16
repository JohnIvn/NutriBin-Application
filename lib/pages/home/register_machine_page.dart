import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutribin_application/services/machine_service.dart';

class RegisterMachinePage extends StatefulWidget {
  const RegisterMachinePage({super.key});

  @override
  State<RegisterMachinePage> createState() => _RegisterMachinePageState();
}

class _RegisterMachinePageState extends State<RegisterMachinePage> {
  // Controllers
  final _machineNameController = TextEditingController();
  final _machineIdController = TextEditingController();
  final _wifiNameController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  // ignore: unused_field
  bool _isLoading = false;
  bool _isBluetoothScanning = false;

  void _showBluetoothPairing() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final primaryColor = Theme.of(context).colorScheme.primary;
            final textColor = Theme.of(context).colorScheme.onSurface;
            final subTextColor =
                Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
            final bgColor = Theme.of(context).scaffoldBackgroundColor;

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bluetooth Pairing',
                          style: GoogleFonts.interTight(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor),
                          onPressed: () {
                            setModalState(() => _isBluetoothScanning = false);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                  Expanded(
                    child: _isBluetoothScanning
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Scanning for nearby devices...',
                                style: GoogleFonts.interTight(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Make sure your NutriBin is powered on.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bluetooth_disabled_rounded,
                                size: 64,
                                color: Colors.grey.withOpacity(0.35),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No devices found',
                                style: GoogleFonts.interTight(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Scan for Devices" to begin.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => setModalState(
                          () => _isBluetoothScanning = !_isBluetoothScanning,
                        ),
                        icon: Icon(
                          _isBluetoothScanning
                              ? Icons.stop_rounded
                              : Icons.bluetooth_searching_rounded,
                        ),
                        label: Text(
                          _isBluetoothScanning
                              ? 'Stop Scanning'
                              : 'Scan for Devices',
                          style: GoogleFonts.interTight(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan QR Code',
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      final scannedCode = barcode.rawValue!;
                      setState(() {
                        _machineIdController.text = scannedCode;
                      });
                      Navigator.pop(context);

                      // Show a brief message before triggering registration
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Processing QR Code..."),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // Automatically trigger registration
                      _handleRegisterMachine();
                      break;
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _machineNameController.dispose();
    _machineIdController.dispose();
    _wifiNameController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
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

    // --- APP BAR CONFIG ---
    final appBarBg = isDarkMode ? backgroundColor : primaryColor;
    const appBarContentColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
        systemOverlayStyle: SystemUiOverlayStyle.light,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: appBarContentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Register Machine',
          style: GoogleFonts.interTight(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appBarContentColor,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.transparent, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Device',
                style: GoogleFonts.interTight(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your NutriBin to start monitoring.',
                style: GoogleFonts.inter(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 24),

              _buildSectionCard(
                context: context,
                title: 'Pair via Bluetooth',
                subtitle:
                    'Automatically detect nearby NutriBin devices. No Wi-Fi required.',
                icon: Icons.bluetooth_rounded,
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showBluetoothPairing,
                    icon: const Icon(Icons.bluetooth_searching_rounded),
                    label: Text(
                      'Scan for Devices',
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionCard(
                context: context,
                title: 'Scan QR Code',
                subtitle:
                    'Scan the QR code on your NutriBin machine to register it automatically.',
                icon: Icons.qr_code_scanner_rounded,
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showScanner,
                    icon: const Icon(Icons.center_focus_weak_rounded),
                    label: Text(
                      'Open QR Scanner',
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionCard(
                context: context,
                title: 'Manual Entry',
                subtitle:
                    'Enter your machine details and Wi-Fi credentials manually.',
                icon: Icons.edit_note_rounded,
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _machineIdController,
                      label: 'Machine ID',
                      hint: 'e.g. NB-123456',
                      icon: Icons.fingerprint_rounded,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: isDarkMode ? Colors.black12 : Colors.grey[50]!,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegisterMachine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Register Machine",
                                style: GoogleFonts.interTight(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
    required bool isDarkMode,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        // Dark Mode: Subtle border, no shadow
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : null,
        // Light Mode: Subtle shadow
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 4),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDarkMode ? Colors.white : primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.interTight(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: subTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    required Color primaryColor,
    required Color cardColor, // Background color for input
    required Color textColor,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.inter(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: textColor.withOpacity(0.3)),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: isDarkMode
                  ? Colors.white70
                  : primaryColor.withOpacity(0.7),
            ),
            filled: true,
            fillColor: cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.transparent : Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegisterMachine() async {
    final serialId = _machineIdController.text.trim();

    if (serialId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Machine ID is required")));
      return;
    }

    setState(() => _isLoading = true);

    final response = await MachineService.registerMachine(serialId: serialId);

    setState(() => _isLoading = false);

    if (response["ok"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Machine registered")),
      );
      await MachineService.fetchExistingMachines();
      _machineIdController.clear();
      _wifiNameController.clear();
      _wifiPasswordController.clear();

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Registration failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
