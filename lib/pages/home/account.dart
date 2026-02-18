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

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "User";
  String userEmail = "user@example.com";
  String? profileUrl;
  bool _isProfileLoading = true; // <-- NEW

  // Shimmer animation controller
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _loadUserProfile();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
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

        _isProfileLoading = false; // <-- NEW
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
                // Swap between skeleton and real header
                _isProfileLoading
                    ? _buildProfileHeaderSkeleton(cardColor, isDarkMode)
                    : _buildProfileHeader(
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
                  icon: Icons.build_circle_outlined,
                  title: 'Repair Status',
                  onTap: () => Navigator.pushNamed(context, '/repair-status'),
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
                    'v2.0.9',
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

  // ── SKELETON HEADER ────────────────────────────────────────────────────────

  Widget _buildProfileHeaderSkeleton(Color cardColor, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        border: isDarkMode
            ? const Border(bottom: BorderSide(color: Colors.white10))
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
            // Circle skeleton
            _ShimmerBox(
              animation: _shimmerAnimation,
              isDarkMode: isDarkMode,
              width: 70,
              height: 70,
              borderRadius: 35,
            ),
            const SizedBox(width: 20),
            // Text skeletons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(
                    animation: _shimmerAnimation,
                    isDarkMode: isDarkMode,
                    width: 140,
                    height: 18,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 8),
                  _ShimmerBox(
                    animation: _shimmerAnimation,
                    isDarkMode: isDarkMode,
                    width: 180,
                    height: 14,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 10),
                  _ShimmerBox(
                    animation: _shimmerAnimation,
                    isDarkMode: isDarkMode,
                    width: 70,
                    height: 12,
                    borderRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── REAL HEADER ────────────────────────────────────────────────────────────

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
        border: isDarkMode
            ? const Border(bottom: BorderSide(color: Colors.white10))
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

// ── SHIMMER BOX WIDGET ───────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final Animation<double> animation;
  final bool isDarkMode;
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.animation,
    required this.isDarkMode,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDarkMode
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE0E0E0);
    final highlightColor = isDarkMode
        ? const Color(0xFF3D3D3D)
        : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(animation.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
