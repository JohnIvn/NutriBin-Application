import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/pages/home/mfa_settings.dart';
import 'package:nutribin_application/services/account_service.dart';
import 'package:nutribin_application/services/auth_service.dart';
import 'package:nutribin_application/utils/helpers.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Profile data state
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String mfaType = 'disable';
  String? profileUrl;

  bool isLoading = true;
  String? errorMessage;

  // Shimmer animation
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
    _fetchAccount();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
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

      final pfp = await ProfileUtility.fetchPfp();

      if (!mounted) return;

      setState(() {
        firstName = profile["firstName"]?.toString() ?? '';
        lastName = profile["lastName"]?.toString() ?? '';
        phoneNumber = profile["contact"]?.toString() ?? '';
        address = profile["address"]?.toString() ?? '';
        email = profile["email"]?.toString() ?? '';

        if (pfp["ok"] == true && pfp["data"] != null) {
          profileUrl = pfp["data"]["avatar"];
        }
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final appBarBg = isDarkMode ? backgroundColor : primaryColor;
    const appBarContentColor = Colors.white;
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
      body: errorMessage != null
          ? _buildErrorView(appBarContentColor)
          : isLoading
          ? _buildSkeletonBody(backgroundColor, cardColor, isDarkMode)
          : _buildContent(
              primaryColor,
              backgroundColor,
              cardColor,
              textColor,
              subTextColor,
              highlightColor,
              isDarkMode,
            ),
    );
  }

  // ── SKELETON ───────────────────────────────────────────────────────────────

  Widget _buildSkeletonBody(
    Color backgroundColor,
    Color cardColor,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Circle avatar skeleton
        _ShimmerBox(
          animation: _shimmerAnimation,
          isDarkMode: isDarkMode,
          width: 100,
          height: 100,
          borderRadius: 50,
        ),
        const SizedBox(height: 16),

        // Name skeleton
        _ShimmerBox(
          animation: _shimmerAnimation,
          isDarkMode: isDarkMode,
          width: 160,
          height: 20,
          borderRadius: 8,
        ),
        const SizedBox(height: 8),

        // Email skeleton
        _ShimmerBox(
          animation: _shimmerAnimation,
          isDarkMode: isDarkMode,
          width: 200,
          height: 14,
          borderRadius: 8,
        ),
        const SizedBox(height: 32),

        // Content card area
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title skeleton
                  _ShimmerBox(
                    animation: _shimmerAnimation,
                    isDarkMode: isDarkMode,
                    width: 120,
                    height: 18,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 16),

                  // Info row skeletons
                  _buildRowSkeleton(cardColor, isDarkMode),
                  const SizedBox(height: 12),
                  _buildRowSkeleton(cardColor, isDarkMode),
                  const SizedBox(height: 12),
                  _buildRowSkeleton(cardColor, isDarkMode),

                  const SizedBox(height: 32),

                  // Security section title
                  _ShimmerBox(
                    animation: _shimmerAnimation,
                    isDarkMode: isDarkMode,
                    width: 90,
                    height: 18,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 16),

                  // MFA row skeleton
                  _buildRowSkeleton(cardColor, isDarkMode, tall: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRowSkeleton(
    Color cardColor,
    bool isDarkMode, {
    bool tall = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Icon placeholder
          _ShimmerBox(
            animation: _shimmerAnimation,
            isDarkMode: isDarkMode,
            width: 24,
            height: 24,
            borderRadius: 6,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  animation: _shimmerAnimation,
                  isDarkMode: isDarkMode,
                  width: 80,
                  height: 11,
                  borderRadius: 4,
                ),
                const SizedBox(height: 6),
                _ShimmerBox(
                  animation: _shimmerAnimation,
                  isDarkMode: isDarkMode,
                  width: tall ? 140 : 160,
                  height: 14,
                  borderRadius: 4,
                ),
                if (tall) ...[
                  const SizedBox(height: 8),
                  _ShimmerBox(
                    animation: _shimmerAnimation,
                    isDarkMode: isDarkMode,
                    width: 70,
                    height: 22,
                    borderRadius: 8,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── REAL CONTENT ───────────────────────────────────────────────────────────

  Widget _buildContent(
    Color primaryColor,
    Color backgroundColor,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color highlightColor,
    bool isDarkMode,
  ) {
    const appBarContentColor = Colors.white;

    return Column(
      children: [
        const SizedBox(height: 20),
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: profileUrl != null && profileUrl!.isNotEmpty
                ? Colors.transparent
                : _getAvatarColor(isDarkMode),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          child: profileUrl != null && profileUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    profileUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getAvatarColor(isDarkMode),
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
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                )
              : Center(
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
                    value: phoneNumber.isEmpty ? 'Not set' : phoneNumber,
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

                  _buildMfaStatusRow(
                    cardColor,
                    textColor,
                    subTextColor,
                    isDarkMode,
                  ),

                  const SizedBox(height: 24),

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

// ── SHIMMER WIDGETS ──────────────────────────────────────────────────────────

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
