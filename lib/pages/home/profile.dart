import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/pages/home/mfa_settings.dart';
import 'package:nutribin_application/utils/helpers.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Profile data state
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String mfaType = 'disable'; // 'disable', 'email', or 'sms'

  bool isLoading = true;
  String? errorMessage;

  // Color scheme
  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => const Color(0xFF57636C);

  @override
  void initState() {
    super.initState();
    _fetchAccount();
  }

  String _getInitials() {
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials.isEmpty ? '?' : initials;
  }

  Color _getAvatarColor() {
    final name = '$firstName$lastName';
    if (name.isEmpty) return _primaryColor;

    final colors = [
      const Color(0xFF4285F4), // Google Blue
      const Color(0xFFEA4335), // Google Red
      const Color(0xFFFBBC04), // Google Yellow
      const Color(0xFF34A853), // Google Green
      const Color(0xFFFF6D00), // Deep Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFE91E63), // Pink
    ];

    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  void _reloadAccount() {
    _fetchAccount();
  }

  void _fetchAccount() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final profile = await PreferenceUtility.getProfile(
        name: true,
        contacts: true,
        email: true,
      );

      if (!mounted) return;

      setState(() {
        firstName = profile["firstName"]?.toString() ?? '';
        lastName = profile["lastName"]?.toString() ?? '';
        phoneNumber = profile["contact"]?.toString() ?? '';
        address = profile["address"]?.toString() ?? '';
        email = profile["email"]?.toString() ?? '';

        // Set MFA type based on profile data
        final mfaValue = profile["mfa"];
        if (mfaValue == true || mfaValue == 'true' || mfaValue == 'email') {
          mfaType = 'email';
        } else if (mfaValue == 'sms') {
          mfaType = 'sms';
        } else {
          mfaType = 'disable';
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load profile';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: _primaryColor,
        appBar: AppBar(
          backgroundColor: _secondaryBackground,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: _secondaryText,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _secondaryText,
            ),
          ),
          actions: [
            if (errorMessage != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchAccount,
                tooltip: 'Retry',
              ),
          ],
          centerTitle: false,
          elevation: 0,
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Loading profile...',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to Load Profile',
                        style: GoogleFonts.interTight(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchAccount,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getAvatarColor(),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(),
                          style: GoogleFonts.inter(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$firstName $lastName',
                      style: GoogleFonts.interTight(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _secondaryBackground,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Color(0x33000000),
                              offset: Offset(0, -1),
                            ),
                          ],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Information',
                                  style: GoogleFonts.interTight(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: _secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildProfileRow(
                                  icon: Icons.person_outline,
                                  label: 'First Name',
                                  value: firstName.isEmpty
                                      ? 'Not set'
                                      : firstName,
                                ),
                                _buildProfileRow(
                                  icon: Icons.person_outline,
                                  label: 'Last Name',
                                  value: lastName.isEmpty
                                      ? 'Not set'
                                      : lastName,
                                ),
                                _buildProfileRow(
                                  icon: Icons.gps_fixed,
                                  label: 'Address',
                                  value: address.isEmpty ? 'Not set' : address,
                                ),
                                _buildProfileRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone Number',
                                  value: phoneNumber.isEmpty
                                      ? 'Not set'
                                      : phoneNumber,
                                ),
                                _buildProfileRow(
                                  icon: Icons.mail_outline,
                                  label: 'Email',
                                  value: email.isEmpty ? 'Not set' : email,
                                ),

                                // Security Section
                                const SizedBox(height: 24),
                                Text(
                                  'Security',
                                  style: GoogleFonts.interTight(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: _secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // MFA Status Row
                                _buildMfaStatusRow(),

                                const SizedBox(height: 24),
                                _buildActionButton(
                                  icon: Icons.edit_outlined,
                                  label: 'Edit Profile',
                                  onTap: () async {
                                    final didUpdate = await Navigator.pushNamed(
                                      context,
                                      '/account-edit',
                                    );

                                    if (didUpdate == true) {
                                      _reloadAccount();
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                  icon: Icons.lock_outline,
                                  label: 'Change Password',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/forgot-password',
                                    );
                                  },
                                ),
                                const SizedBox(height: 64),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
    double bottomPadding = 12,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E3E7), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: _primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF101213),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMfaStatusRow() {
    final bool isEnabled = mfaType != 'disable';
    String statusText = 'Disabled';
    IconData statusIcon = Icons.cancel;

    if (mfaType == 'email') {
      statusText = 'Email';
      statusIcon = Icons.email_outlined;
    } else if (mfaType == 'sms') {
      statusText = 'SMS';
      statusIcon = Icons.sms_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E7), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12), // optional for nicer ripple
        onTap: () {
          // Navigator.pushNamed(context, "/mfa-settings");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MfaSettingsPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ), // gives better tap area
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: isEnabled ? const Color(0xFF34A853) : _secondaryText,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Two-Factor Authentication',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? const Color(0xFF34A853).withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: 14,
                                color: isEnabled
                                    ? const Color(0xFF34A853)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isEnabled
                                      ? const Color(0xFF34A853)
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: _secondaryText, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: _primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: _primaryColor, size: 16),
          ],
        ),
      ),
    );
  }
}
