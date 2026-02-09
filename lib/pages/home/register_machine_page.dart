import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

              // QR SECTION
              _buildSectionCard(
                context: context,
                title: 'Scan QR Code',
                subtitle:
                    'Quickly register by scanning the QR code found on your NutriBin machine.',
                icon: Icons.qr_code_scanner_rounded,
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // To Do: implement scanner
                    },
                    icon: Icon(Icons.camera_alt_outlined, color: Colors.white),
                    label: Text(
                      'Scan QR Code',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Divider(color: subTextColor.withOpacity(0.3)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subTextColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: subTextColor.withOpacity(0.3)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MANUAL SECTION
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
                      controller: _machineNameController,
                      label: 'Machine Name',
                      hint: 'e.g. Kitchen Bin',
                      icon: Icons.label_outline_rounded,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: isDarkMode ? Colors.black12 : Colors.grey[50]!,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _wifiNameController,
                      label: 'Wi-Fi Name (SSID)',
                      hint: 'Your network name',
                      icon: Icons.wifi_rounded,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: isDarkMode ? Colors.black12 : Colors.grey[50]!,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _wifiPasswordController,
                      label: 'Wi-Fi Password',
                      hint: 'Network password',
                      icon: Icons.lock_outline_rounded,
                      isObscure: true,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: isDarkMode ? Colors.black12 : Colors.grey[50]!,
                      textColor: textColor,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
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
}
