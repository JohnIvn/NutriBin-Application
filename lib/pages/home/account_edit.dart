import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutribin_application/models/user.dart';
import 'package:nutribin_application/services/account_service.dart';
import 'package:nutribin_application/services/auth_service.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:nutribin_application/widgets/map_picker.dart';

class AccountEditWidget extends StatefulWidget {
  final VoidCallback? onSaved;

  const AccountEditWidget({super.key, this.onSaved});

  static String routeName = 'AccountEdit';
  static String routePath = '/accountEdit';

  @override
  State<AccountEditWidget> createState() => _AccountEditWidgetState();
}

class _AccountEditWidgetState extends State<AccountEditWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Text controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;

  // Focus nodes
  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _addressFocusNode;
  late FocusNode _contactFocusNode;

  bool isLoading = true;
  String? errorMessage;
  String? _originalContact;

  // Profile picture state
  String? profileUrl;
  File? _newProfileImage;
  bool _shouldDeleteProfilePic = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();

    // Initialize focus nodes
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _contactFocusNode = FocusNode();

    _fetchAccount();
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();

    // Dispose focus nodes
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _addressFocusNode.dispose();
    _contactFocusNode.dispose();

    super.dispose();
  }

  String _getInitials() {
    String initials = '';
    if (_firstNameController.text.isNotEmpty) {
      initials += _firstNameController.text[0];
    }
    if (_lastNameController.text.isNotEmpty) {
      initials += _lastNameController.text[0];
    }
    return initials.isEmpty ? '?' : initials.toUpperCase();
  }

  Color _getAvatarColor(bool isDarkMode) {
    final name = '${_firstNameController.text}${_lastNameController.text}';
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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _newProfileImage = File(pickedFile.path);
          _shouldDeleteProfilePic =
              false; // Cancel deletion if new image is picked
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _deleteProfilePicture() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(
          'Delete Profile Picture',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete your profile picture?',
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
              setState(() {
                _shouldDeleteProfilePic = true;
                _newProfileImage = null;
                profileUrl = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProfilePictureOptions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: textColor),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.inter(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (profileUrl != null || _newProfileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete Profile Picture',
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteProfilePicture();
                  },
                ),
              ListTile(
                leading: Icon(Icons.cancel, color: textColor.withOpacity(0.6)),
                title: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: textColor.withOpacity(0.6)),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final appBarBg = isDarkMode ? cardColor : primaryColor;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
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
          'Edit Profile',
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.red),
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 24),

                    // Profile Picture Section
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _showProfilePictureOptions,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    (_newProfileImage != null ||
                                        (profileUrl != null &&
                                            !_shouldDeleteProfilePic))
                                    ? Colors.transparent
                                    : _getAvatarColor(isDarkMode),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: _buildProfileImage(isDarkMode),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showProfilePictureOptions,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: backgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Row(
                        children: [
                          Text(
                            'Your information',
                            style: GoogleFonts.interTight(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Name
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _firstNameController,
                              focusNode: _firstNameFocusNode,
                              style: GoogleFonts.inter(color: textColor),
                              decoration: _inputDecoration(
                                'First Name',
                                cardColor: cardColor,
                                textColor: textColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ),

                          // Last Name
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _lastNameController,
                              focusNode: _lastNameFocusNode,
                              style: GoogleFonts.inter(color: textColor),
                              decoration: _inputDecoration(
                                'Last Name',
                                cardColor: cardColor,
                                textColor: textColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ),

                          // Address
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _addressController,
                              focusNode: _addressFocusNode,
                              readOnly: true,
                              style: GoogleFonts.inter(color: textColor),
                              onTap: _openMapPicker,
                              decoration:
                                  _inputDecoration(
                                    'Address',
                                    hint: 'Brgy 123 Phase 1 Purok 1',
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    isDarkMode: isDarkMode,
                                  ).copyWith(
                                    suffixIcon: Icon(
                                      Icons.location_on_outlined,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF57636C),
                                    ),
                                  ),
                            ),
                          ),

                          // Contact Number
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _contactController,
                                  focusNode: _contactFocusNode,
                                  keyboardType: TextInputType.phone,
                                  style: GoogleFonts.inter(color: textColor),
                                  decoration: _inputDecoration(
                                    'Contact Number',
                                    hint: '09123456789',
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                                if (_contactController.text.trim() !=
                                    _originalContact)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Changing your contact number requires verification',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Save button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(270, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.interTight(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  Widget _buildProfileImage(bool isDarkMode) {
    // Show new image if selected
    if (_newProfileImage != null) {
      return ClipOval(
        child: Image.file(
          _newProfileImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    // Show existing profile URL if available and not marked for deletion
    if (profileUrl != null && !_shouldDeleteProfilePic) {
      return ClipOval(
        child: Image.network(
          profileUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar();
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
                color: Colors.white,
              ),
            );
          },
        ),
      );
    }

    // Show initials as fallback
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        _getInitials(),
        style: GoogleFonts.inter(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _fetchAccount() async {
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
        _firstNameController.text = profile["firstName"]?.toString() ?? '';
        _lastNameController.text = profile["lastName"]?.toString() ?? '';
        _addressController.text = profile["address"]?.toString() ?? '';
        _contactController.text = profile["contact"]?.toString() ?? '';
        _originalContact = profile["contact"]?.toString() ?? '';

        // Set profile picture URL
        if (pfp["ok"] == true && pfp["data"] != null) {
          profileUrl = pfp["data"]["avatar"];
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load account: $e';
      });
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerPage()),
    );

    if (result != null && result is String) {
      setState(() {
        _addressController.text = result;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateChanges() {
    // Auto-trim inputs
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final contact = _contactController.text.trim();

    // Update controllers with trimmed values
    _firstNameController.text = firstName;
    _lastNameController.text = lastName;
    _contactController.text = contact;

    // Name validation: letters and spaces only
    final nameRegex = RegExp(r'^[A-Za-z\s]+$');

    if (firstName.isEmpty || !nameRegex.hasMatch(firstName)) {
      _showError('First name must contain letters only');
      return false;
    }

    if (lastName.isEmpty || !nameRegex.hasMatch(lastName)) {
      _showError('Last name must contain letters only');
      return false;
    }

    // Contact validation
    if (contact.isNotEmpty) {
      if (contact.startsWith("09")) {
        if (contact.length != 11 || !RegExp(r'^\d+$').hasMatch(contact)) {
          _showError('Contact must be 09 followed by 9 digits');
          return false;
        }
      } else {
        _showError('Contact must start with 09');
        return false;
      }
    }

    return true;
  }

  Future<void> _handleSave() async {
    if (!_validateChanges()) return;

    final currentContact = _contactController.text.trim();
    final contactChanged = currentContact != _originalContact;

    // If contact changed, verify it first
    if (contactChanged && currentContact.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        // Send verification code to the new contact number
        final sendCodeResult = await AuthUtility.sendContactVerification(
          contact: currentContact,
        );

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        if (sendCodeResult["ok"] != true) {
          _showError(
            sendCodeResult["message"] ?? "Failed to send verification code",
          );
          return;
        }

        // Navigate to verification screen
        final verificationResult = await Navigator.pushNamed(
          context,
          '/verify-contacts',
          arguments: {'recipient': currentContact, 'type': 'sms'},
        );

        if (verificationResult == null) {
          _showError('Verification Cancelled');
          return;
        }

        if (!mounted) return;

        final otpResult = verificationResult as Map<String, dynamic>;

        // Check if verification was successful
        if (otpResult["ok"] != true) {
          _showError(otpResult["error"] ?? 'OTP verification failed');
          return;
        }

        final verifyContactResult = await AuthUtility.verifyContact(
          newPhone: currentContact,
          code: otpResult["otp"],
        );

        if (verifyContactResult["ok"] != true) {
          _showError(
            verifyContactResult["message"] ?? "Contact verification failed",
          );
          return;
        }
        // Verification successful, proceed with update
        _performUpdate();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        _showError('Failed to send verification code: $e');
      }
    } else {
      // No contact change, proceed with update directly
      _performUpdate();
    }
  }

  Future<void> _performUpdate() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Handle profile picture operations first
      if (_shouldDeleteProfilePic) {
        // Delete profile picture
        final deleteResult = await ProfileUtility.deletePfp();
        if (deleteResult["ok"] != true) {
          if (!mounted) return;
          _showError('Failed to delete profile picture');
          setState(() {
            isLoading = false;
          });
          return;
        }
      } else if (_newProfileImage != null) {
        // Upload new profile picture
        final uploadResult = await ProfileUtility.uploadPfp(_newProfileImage!);
        if (uploadResult["ok"] != true) {
          if (!mounted) return;
          _showError(
            uploadResult["message"] ??
                uploadResult["error"] ??
                'Failed to upload profile picture',
          );
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      // Update user information
      final result = await AuthUtility.updateUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        contact: _contactController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (!mounted) return;

      if (result["ok"] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["data"]?.toString() ?? "Update failed"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Extract user object
      final user = User.fromJson(result["data"]);

      await PreferenceUtility.saveSession(
        user.id,
        user.email,
        user.firstName,
        user.lastName,
        user.contact,
        user.address,
        user.mfa,
        user.token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account updated successfully!"),
          backgroundColor: Color.fromARGB(255, 0, 134, 4),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update account: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(
    String label, {
    String? hint,
    required Color cardColor,
    required Color textColor,
    required bool isDarkMode,
  }) {
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey[300]!;
    final focusedBorderColor = isDarkMode ? Colors.white70 : Colors.black;

    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        color: isDarkMode ? Colors.white70 : Colors.grey[600],
      ),
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: isDarkMode ? Colors.white30 : Colors.grey[400],
      ),
      filled: true,
      fillColor: cardColor,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
