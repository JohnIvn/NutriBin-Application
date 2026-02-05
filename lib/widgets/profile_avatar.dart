import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.size = 100,
    this.showBorder = true,
    this.onTap,
  });

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
    if (name.isEmpty) return const Color(0xFF4285F4);

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

  @override
  Widget build(BuildContext context) {
    final avatarWidget = photoUrl != null && photoUrl!.isNotEmpty
        ? _buildPhotoAvatar()
        : _buildInitialsAvatar();

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatarWidget);
    }

    return avatarWidget;
  }

  Widget _buildPhotoAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildInitialsAvatar(),
          errorWidget: (context, url, error) => _buildInitialsAvatar(),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(),
        border: showBorder ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: GoogleFonts.inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
