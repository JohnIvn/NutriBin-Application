import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/services/auth_service.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MfaSettingsPage extends StatefulWidget {
  const MfaSettingsPage({super.key});

  static String routeName = 'MfaSettings';
  static String routePath = '/mfaSettings';

  @override
  State<MfaSettingsPage> createState() => _MfaSettingsPageState();
}

class _MfaSettingsPageState extends State<MfaSettingsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _mfaType = 'disable';
  bool _isMfaLoading = false;
  bool _isInitialLoading = true;
  bool _isPhoneVerified = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPhone();
    _fetchMfaSettings();
  }

  Future<void> _fetchPhone() async {
    String? contact = await PreferenceUtility.getContact();
    if (contact == null) return;
    setState(() {
      _isPhoneVerified = contact.toString().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- HIGHLIGHT COLOR FIX ---
    final highlightColor = isDarkMode ? const Color(0xFF8FAE8F) : primaryColor;

    // AppBar Colors
    final appBarBg = isDarkMode ? backgroundColor : primaryColor;
    const appBarContentColor = Colors.white;

    // Info Box Colors (Adaptive Blue)
    final infoBoxBg = isDarkMode ? Colors.blue.withOpacity(0.15) : Colors.blue[50];
    final infoBoxBorder = isDarkMode ? Colors.blue.withOpacity(0.3) : Colors.blue[200]!;
    final infoBoxText = isDarkMode ? Colors.blue[100] : Colors.blue[900];
    final infoBoxIcon = isDarkMode ? Colors.blue[200] : Colors.blue[700];

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: appBarContentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Two-Factor Authentication',
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
        child: _isInitialLoading
            ? Center(child: CircularProgressIndicator(color: highlightColor))
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMfaSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure Your Account',
                            style: GoogleFonts.interTight(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add an extra layer of security by requiring a verification code in addition to your password.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: subTextColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // MFA Options Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: isDarkMode 
                            ? Border.all(color: Colors.white.withOpacity(0.05)) 
                            : Border.all(color: Colors.grey[300]!),
                        boxShadow: isDarkMode ? [] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.security, color: highlightColor, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Authentication Method',
                                  style: GoogleFonts.interTight(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (_isMfaLoading)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: highlightColor,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Radio buttons
                          _buildMfaRadioOption(
                            value: 'disable',
                            title: 'Disabled',
                            subtitle: 'No two-factor authentication',
                            icon: Icons.cancel_outlined,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            highlightColor: highlightColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildMfaRadioOption(
                            value: 'email',
                            title: 'Email Verification',
                            subtitle: 'Send code to your email address',
                            icon: Icons.email_outlined,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            highlightColor: highlightColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildMfaRadioOption(
                            value: 'sms',
                            title: 'SMS Verification',
                            subtitle: 'Send code to your phone number',
                            icon: Icons.sms_outlined,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            highlightColor: highlightColor,
                            isDarkMode: isDarkMode,
                          ),

                          // Active Status Indicator
                          if (_mfaType != 'disable')
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: highlightColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: highlightColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: highlightColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Protected with ${_mfaType.toUpperCase()} 2FA',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: highlightColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Info Section
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: infoBoxBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: infoBoxBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: infoBoxIcon,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'When enabled, you\'ll need to enter a verification code each time you sign in to your account.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: infoBoxText,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ... (Fetch logic remains unchanged)
  Future<void> _fetchMfaSettings() async {
    try {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
      });
      final response = await AuthUtility.fetchMfa();

      if (response["ok"] != true) {
        setState(() {
          _isInitialLoading = false;
          _errorMessage = response["message"] ?? "Failed to fetch MFA settings";
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        final mfaValue = response["data"]?.toString() ?? 'N/A';
        if (mfaValue == 'N/A' || mfaValue == 'false') {
          _mfaType = 'disable';
        } else if (mfaValue == 'email') {
          _mfaType = 'email';
        } else if (mfaValue == 'sms') {
          _mfaType = 'sms';
        } else {
          _mfaType = 'disable';
        }
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _errorMessage = 'Failed to load MFA settings: $e';
      });
    }
  }

  Future<void> _handleMfaToggle(String type) async {
    setState(() => _isMfaLoading = true);

    try {
      final result = await AuthUtility.toggleMfa(type: type);
      if (!mounted) return;

      if (result["ok"] == true) {
        setState(() {
          _mfaType = type;
          _isMfaLoading = false;
        });

        final mfaTypeFromResponse = result["data"]?.toString() ?? 'N/A';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mfa', mfaTypeFromResponse);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(type == 'disable' ? '2FA Disabled' : '2FA Enabled via ${type.toUpperCase()}'),
            backgroundColor: const Color(0xFF34A853), // Success Green
          ),
        );
      } else {
        setState(() => _isMfaLoading = false);
        _showError(result["message"] ?? 'Failed to update MFA settings');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMfaLoading = false);
      _showError('Failed to update MFA settings: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildMfaRadioOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color textColor,
    required Color subTextColor,
    required Color highlightColor,
    required bool isDarkMode,
  }) {
    final isSelected = _mfaType == value;
    final bool isDisabled = value == 'sms' && !_isPhoneVerified;

    // --- COLOR LOGIC ---
    // Border: Highlight if selected, otherwise subtle grey/white
    final borderColor = isSelected 
        ? highlightColor 
        : (isDarkMode ? Colors.white10 : Colors.grey[300]!);
    
    // Ucin Highlight if selected, dimmed if disabled, normal grey if unselected
    final iconColor = isSelected 
        ? highlightColor 
        : (isDisabled ? subTextColor.withOpacity(0.3) : subTextColor);

    // Text White/Black if active, dimmed if disabled
    final titleColor = isDisabled ? subTextColor.withOpacity(0.5) : textColor;
    final subtitleColor = isDisabled ? subTextColor.withOpacity(0.3) : subTextColor;

    return InkWell(
      onTap: (_isMfaLoading || isDisabled) ? null : () => _handleMfaToggle(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? highlightColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _mfaType,
              activeColor: highlightColor,
              onChanged: (_isMfaLoading || isDisabled)
                  ? null
                  : (String? newValue) {
                      if (newValue != null) _handleMfaToggle(newValue);
                    },
            ),
          ],
        ),
      ),
    );
  }
}