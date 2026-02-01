import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "";
  String userEmail = "";

  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryColor => const Color(0xFF39D2C0);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => const Color(0xFF57636C);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  String _getInitials() {
    final parts = userName.trim().split(RegExp(r'\s+'));

    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials += parts[0][0].toUpperCase();
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }

    return initials.isEmpty ? '?' : initials;
  }

  Color _getAvatarColor() {
    final name = userName.replaceAll(' ', '');
    if (name.isEmpty) return _primaryColor;

    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFFEA4335), // Red
      const Color(0xFFFBBC04), // Yellow
      const Color(0xFF34A853), // Green
      const Color(0xFFFF6D00), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFE91E63), // Pink
    ];

    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  Future<void> _loadUserProfile() async {
    final Map<String, Object?> user = await PreferenceUtility.getProfile(
      name: true,
      contacts: false,
      email: true,
    );

    setState(() {
      userName = "${user["firstName"] ?? ""} ${user["lastName"] ?? ""}".trim();

      userEmail = user["email"] as String? ?? "";
    });
  }

  Future<void> logOut() async {
    try {
      await PreferenceUtility.clearSession();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/');
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
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logOut();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // DEBUG ONLY - Remove in production
  Future<void> _resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('navbar_tutorial_seen');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tutorial reset! It will show on next app restart.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _secondaryBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // optional, nice effect
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                _buildSectionTitle('Account'),
                _buildMenuItem(
                  icon: Icons.notifications_none,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildSectionTitle('General'),
                _buildMenuItem(
                  icon: Icons.phone,
                  title: 'Support',
                  onTap: () {
                    Navigator.pushNamed(context, '/support');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Terms of Service',
                  onTap: () {
                    Navigator.pushNamed(context, '/termsOfService');
                  },
                ),
                // DEBUG ONLY - Remove in production
                _buildMenuItem(
                  icon: Icons.replay,
                  title: 'Reset Tutorial (Debug)',
                  onTap: _resetTutorial,
                ),
                _buildMenuItem(
                  icon: Icons.exit_to_app,
                  title: 'Log Out',
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Color(0x33000000),
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildLetterAvatar(),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.interTight(
                        color: _secondaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        userEmail,
                        style: GoogleFonts.inter(
                          color: _secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(),
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: _secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 5,
                color: Color(0x3416202A),
                offset: Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon, color: _secondaryText, size: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        color: _secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: _secondaryText, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
