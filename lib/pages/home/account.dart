import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final String _userName = 'Matthew Cania';
  final String _userEmail = 'matthew24@gmail.com';

  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryColor => const Color(0xFF39D2C0);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => const Color(0xFF57636C);

  Future<void> logOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

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
                      _userName,
                      style: GoogleFonts.interTight(
                        color: _secondaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _userEmail,
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
    final nameParts = _userName.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : nameParts[0][0];

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: _secondaryColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: _secondaryColor, width: 2),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: GoogleFonts.inter(
            color: _primaryColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
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
