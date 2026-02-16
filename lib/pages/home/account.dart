import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/services/account_service.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "User";
  String userEmail = "user@example.com";
  String? profileUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final Map<String, Object?> user = await PreferenceUtility.getProfile(
      name: true,
      contacts: false,
      email: true,
    );

    final profile = await ProfileUtility.fetchPfp();


    if (mounted) {
      setState(() {
        if (profile["ok"] == true && profile["data"] != null) {
          profileUrl = profile["data"]["avatar"];
        }

        final first = user["firstName"] as String? ?? "";
        final last = user["lastName"] as String? ?? "";
        userName = "$first $last".trim();
        if (userName.isEmpty) userName = "NutriBin User";

        userEmail = user["email"] as String? ?? "";
      });
    }
  }

  String _getInitials() {
    if (userName.isEmpty) return "?";
    final parts = userName.trim().split(RegExp(r'\s+'));
    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) initials += parts[0][0];
    if (parts.length > 1 && parts[1].isNotEmpty) initials += parts[1][0];
    return initials.toUpperCase();
  }

  Color _getAvatarColor(bool isDarkMode) {
    if (userName.isEmpty) return Theme.of(context).primaryColor;

    // pallette
    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFFEA4335), // Red
      const Color(0xFFFBBC04), // Yellow (Darker)
      const Color(0xFF34A853), // Green
      const Color(0xFFFF6D00), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFE91E63), // Pink
    ];

    final index = userName.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  Future<void> logOut() async {
    try {
      await PreferenceUtility.clearSession();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging out. Please try again.')),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(
          'Log Out',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logOut();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // DEBUG ONLY
  Future<void> _resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('navbar_tutorial_seen');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tutorial reset! Restart app to see it.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME VALUES ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(
                  cardColor,
                  textColor,
                  subTextColor,
                  isDarkMode,
                ),

                const SizedBox(height: 16),

                _buildSectionTitle('Account', subTextColor),
                _buildMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile Settings',
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  cardColor: cardColor,
                  textColor: textColor,
                  isDarkMode: isDarkMode,
                ),

                _buildSectionTitle('General', subTextColor),
                _buildMenuItem(
                  icon: Icons.headset_mic_outlined,
                  title: 'Support',
                  onTap: () => Navigator.pushNamed(context, '/support'),
                  cardColor: cardColor,
                  textColor: textColor,
                  isDarkMode: isDarkMode,
                ),
                _buildMenuItem(
                  icon: Icons.policy_outlined,
                  title: 'Terms of Service',
                  onTap: () => Navigator.pushNamed(context, '/termsOfService'),
                  cardColor: cardColor,
                  textColor: textColor,
                  isDarkMode: isDarkMode,
                ),

                // DEBUG ITEM
                _buildMenuItem(
                  icon: Icons.restart_alt_rounded,
                  title: 'Reset Tutorial (Debug)',
                  onTap: _resetTutorial,
                  cardColor: cardColor,
                  textColor: Colors.orange,
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 24),

                // LOGOUT BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: _handleLogout,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.red.withOpacity(0.1)
                            : Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.inter(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'v2.0.5',
                    style: GoogleFonts.inter(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    Color cardColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        // Bottom border for separation in Dark Mode
        border: isDarkMode
            ? Border(bottom: BorderSide(color: Colors.white10))
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: profileUrl != null && profileUrl!.isNotEmpty
                    ? Colors.transparent
                    : _getAvatarColor(isDarkMode),
                boxShadow: [
                  BoxShadow(
                    color: profileUrl != null && profileUrl!.isNotEmpty
                        ? Colors.black.withOpacity(0.2)
                        : _getAvatarColor(isDarkMode).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: profileUrl != null && profileUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        profileUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to initials if image fails to load
                          return Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getAvatarColor(isDarkMode),
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(),
                                style: GoogleFonts.interTight(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        _getInitials(),
                        style: GoogleFonts.interTight(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.interTight(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: GoogleFonts.inter(color: subTextColor, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // "Edit Profile" hint (optional polish)
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.inter(
                        color: isDarkMode
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isDarkMode ? Border.all(color: Colors.white10) : null,
          boxShadow: isDarkMode
              ? []
              : [
                  const BoxShadow(
                    blurRadius: 2,
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: textColor.withOpacity(0.7), size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textColor.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
