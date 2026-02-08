import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/models/user.dart';
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

  Color get _primaryColor => Theme.of(context).primaryColor;

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
  String? _originalContact; // Store original contact to check if changed
  String _mfaType = 'disable'; // MFA type: 'disable', 'email', or 'sms'
  final bool _isMfaLoading = false; // Loading state for MFA toggle

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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Row(
                        children: [
                          Text(
                            'Your information',
                            style: GoogleFonts.interTight(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
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
                              decoration: _inputDecoration('First Name'),
                            ),
                          ),

                          // Last Name
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _lastNameController,
                              focusNode: _lastNameFocusNode,
                              decoration: _inputDecoration('Last Name'),
                            ),
                          ),

                          // Address
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _addressController,
                              focusNode: _addressFocusNode,
                              readOnly: true,
                              onTap: _openMapPicker,
                              decoration:
                                  _inputDecoration(
                                    'Address',
                                    hint: 'Brgy 123 Phase 1 Purok 1',
                                  ).copyWith(
                                    suffixIcon: const Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFF57636C),
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
                                  decoration: _inputDecoration(
                                    'Contact Number',
                                    hint: '+63 912 345 6789',
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
                                          color: _primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Changing your contact number requires verification',
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
                          backgroundColor: _primaryColor,
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

      if (!mounted) return;

      setState(() {
        _firstNameController.text = profile["firstName"]?.toString() ?? '';
        _lastNameController.text = profile["lastName"]?.toString() ?? '';
        _addressController.text = profile["address"]?.toString() ?? '';
        _contactController.text = profile["contact"]?.toString() ?? '';
        _originalContact = profile["contact"]?.toString() ?? '';

        // Set MFA type based on profile data
        final mfaValue = profile["mfa"];
        if (mfaValue == true || mfaValue == 'true' || mfaValue == 'email') {
          _mfaType = 'email';
        } else if (mfaValue == 'sms') {
          _mfaType = 'sms';
        } else {
          _mfaType = 'disable';
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
      if (contact.startsWith('+')) {
        if (contact.length != 13 || !RegExp(r'^\+\d+$').hasMatch(contact)) {
          _showError('Contact must be +63 followed by 10 digits');
          return false;
        }
      } else if (contact.startsWith('09')) {
        if (contact.length != 11 || !RegExp(r'^\d+$').hasMatch(contact)) {
          _showError('Contact must be 09 followed by 9 digits');
          return false;
        }
      } else {
        _showError('Contact must start with +63 or 09');
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
          arguments: {'recipient': currentContact, 'type': 'contact'},
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

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void autoPrefixPHContact(TextEditingController controller) {
    final text = controller.text;

    if (text.startsWith('09')) {
      final newText = '+63${text.substring(1)}';
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  String normalizePHContact(String value) {
    final contact = value.trim();

    if (contact.startsWith('09')) {
      return '+63${contact.substring(1)}';
    }

    return contact;
  }
}
