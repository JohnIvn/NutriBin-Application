import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/pages/home/mfa_settings.dart';
import 'package:nutribin_application/services/auth_service.dart';
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
  String mfaType = 'disable';

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAccount();
  }

  // --- HELPERS ---

  String _getInitials() {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    return initials.isEmpty ? '?' : initials.toUpperCase();
  }

  Color _getAvatarColor(bool isDarkMode) {
    final name = '$firstName$lastName';
    if (name.isEmpty) return Theme.of(context).primaryColor;

    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFFEA4335),
      const Color(0xFFFBBC04),
      const Color(0xFF34A853),
      const Color(0xFFFF6D00),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFE91E63),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  // --- DATA FETCHING ---

  void _reloadAccount() => _fetchAccount();

  void _fetchMfa() async {
    if (firstName.isEmpty) setState(() => isLoading = true);

    try {
      final response = await AuthUtility.fetchMfa();
      if (mounted) {
        setState(() {
          mfaType = response["data"] ?? "disabled";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
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
      });
      _fetchMfa();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load profile';
      });
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

    // AppBar Colors
    final appBarBg = isDarkMode ? backgroundColor : primaryColor;
    const appBarContentColor = Colors.white;

    // Highlight Color for Dark Mode Icons
    final highlightColor = isDarkMode ? const Color(0xFF8FAE8F) : primaryColor;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: appBarBg,
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
          'Profile',
          style: GoogleFonts.interTight(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appBarContentColor,
          ),
        ),
        actions: [
          if (errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: appBarContentColor),
              onPressed: _fetchAccount,
            ),
        ],
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.transparent, height: 1.0),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: appBarContentColor))
          : errorMessage != null
          ? _buildErrorView(appBarContentColor)
          : Column(
              children: [
                const SizedBox(height: 20),
                // Avatar & Name (Top Section)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getAvatarColor(isDarkMode),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(),
                      style: GoogleFonts.inter(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w700,
                    color: appBarContentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: appBarContentColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 32),

                // Scrollable Content Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: isDarkMode
                          ? []
                          : [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, -2),
                              ),
                            ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Info',
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildProfileRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Full Name',
                            value: '$firstName $lastName',
                            cardColor: cardColor,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            highlightColor: highlightColor,
                            isDarkMode: isDarkMode,
                          ),

                          _buildProfileRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: address.isEmpty ? 'Not set' : address,
                            cardColor: cardColor,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            highlightColor: highlightColor,
                            isDarkMode: isDarkMode,
                          ),

                          _buildProfileRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone Number',
                            value: phoneNumber.isEmpty
                                ? 'Not set'
                                : phoneNumber,
                            cardColor: cardColor,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            highlightColor: highlightColor,
                            isDarkMode: isDarkMode,
                          ),

                          const SizedBox(height: 32),

                          Text(
                            'Security',
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // MFA Status
                          _buildMfaStatusRow(
                            cardColor,
                            textColor,
                            subTextColor,
                            isDarkMode,
                          ),

                          const SizedBox(height: 24),

                          // Action Buttons
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: 'Edit Profile Details',
                            onTap: () async {
                              final didUpdate = await Navigator.pushNamed(
                                context,
                                '/account-edit',
                              );
                              if (didUpdate == true) _reloadAccount();
                            },
                            primaryColor: primaryColor,
                            highlightColor: highlightColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/forgot-password',
                                arguments: {'type': "change"},
                              );
                            },
                            primaryColor: primaryColor,
                            highlightColor: highlightColor,
                            isDarkMode: isDarkMode,
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color highlightColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isDarkMode
              ? Border.all(color: Colors.white.withOpacity(0.05))
              : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: highlightColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: textColor,
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

  Widget _buildMfaStatusRow(
    Color cardColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    final bool isEnabled = mfaType == 'email' || mfaType == 'sms';
    String statusText = 'Disabled';
    IconData statusIcon = Icons.cancel_outlined;

    if (mfaType == 'email') {
      statusText = 'Email';
      statusIcon = Icons.email_outlined;
    } else if (mfaType == 'sms') {
      statusText = 'SMS';
      statusIcon = Icons.sms_outlined;
    }

    final statusColor = isEnabled ? const Color(0xFF34A853) : subTextColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MfaSettingsPage()),
          );
          _fetchMfa();
        },
        child: Row(
          children: [
            Icon(Icons.security_rounded, color: statusColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-Factor Authentication',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: statusColor,
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
            Icon(Icons.chevron_right_rounded, color: subTextColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color highlightColor,
    required bool isDarkMode,
  }) {
    final btnColor = isDarkMode
        ? Colors.white.withOpacity(0.05)
        : primaryColor.withOpacity(0.08);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(12),
          border: isDarkMode
              ? Border.all(color: Colors.white.withOpacity(0.05))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: highlightColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: highlightColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: highlightColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(Color contentColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: contentColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Profile',
            style: GoogleFonts.interTight(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: contentColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchAccount,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
