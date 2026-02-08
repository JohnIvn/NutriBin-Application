import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/models/user.dart';
import 'package:nutribin_application/services/account_service.dart';
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

  Color get _primaryColor => Theme.of(context).primaryColor;

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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: _primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Two-Factor Authentication',
          style: GoogleFonts.interTight(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isInitialLoading
            ? const Center(child: CircularProgressIndicator())
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
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMfaSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
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
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Two-factor authentication adds an extra layer of security to your account by requiring a verification code in addition to your password.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          boxShadow: [
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
                                Icon(
                                  Icons.security,
                                  color: _primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Authentication Method',
                                    style: GoogleFonts.interTight(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                if (_isMfaLoading)
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Radio buttons for MFA options
                            _buildMfaRadioOption(
                              value: 'disable',
                              title: 'Disabled',
                              subtitle: 'No two-factor authentication',
                              icon: Icons.cancel_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildMfaRadioOption(
                              value: 'email',
                              title: 'Email Verification',
                              subtitle: 'Send code to your email address',
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildMfaRadioOption(
                              value: 'sms',
                              title: 'SMS Verification',
                              subtitle: 'Send code to your phone number',
                              icon: Icons.sms_outlined,
                            ),

                            if (_mfaType != 'disable')
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: _primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Your account is protected with ${_mfaType.toUpperCase()} 2FA',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: _primaryColor,
                                            fontWeight: FontWeight.w500,
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
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'When enabled, you\'ll need to enter a verification code each time you sign in to your account.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.blue[900],
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
      ),
    );
  }

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

        print("🔍 Fetched MFA type: $mfaValue -> Mapped to: $_mfaType");
        _isInitialLoading = false;
      });
    } catch (e) {
      print("Error fetching MFA: $e");
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _errorMessage = 'Failed to load MFA settings: $e';
      });
    }
  }

  Future<void> _handleMfaToggle(String type) async {
    setState(() {
      _isMfaLoading = true;
    });

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
            content: Text(
              type == 'disable'
                  ? 'Two-factor authentication disabled'
                  : 'Two-factor authentication enabled via ${type.toUpperCase()}',
            ),
            backgroundColor: const Color.fromARGB(255, 0, 134, 4),
          ),
        );
      } else {
        setState(() {
          _isMfaLoading = false;
        });
        _showError(result["message"] ?? 'Failed to update MFA settings');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isMfaLoading = false;
      });
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
  }) {
    final isSelected = _mfaType == value;

    // 👉 Disable SMS if phone not verified
    final bool isDisabled = value == 'sms' && !_isPhoneVerified;

    return InkWell(
      onTap: (_isMfaLoading || isDisabled)
          ? null
          : () => _handleMfaToggle(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryColor.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? _primaryColor
                : isDisabled
                ? Colors.grey[300]!
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          // 👈 visually dim if disabled
          opacity: isDisabled ? 0.5 : 1,
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? _primaryColor
                    : isDisabled
                    ? Colors.grey[400]
                    : Colors.grey[600],
                size: 24,
              ),
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
                        color: isSelected
                            ? _primaryColor
                            : isDisabled
                            ? Colors.grey[400]
                            : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: _mfaType,
                activeColor: _primaryColor,
                onChanged: (_isMfaLoading || isDisabled)
                    ? null
                    : (String? newValue) {
                        if (newValue != null) {
                          _handleMfaToggle(newValue);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
