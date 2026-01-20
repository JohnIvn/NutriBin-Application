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
  Color get _secondaryColor => const Color(0xFFA63000);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => const Color(0xFF57636C);

  // Text controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;

  // Focus nodes
  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _addressFocusNode;
  late FocusNode _contactFocusNode;

  bool isLoading = true;
  String? errorMessage;

  // Form state
  String? selectedGender;
  DateTime? selectedBirthday;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _birthdayController = TextEditingController();
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
    _birthdayController.dispose();
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

                          // Gender label
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 0, 4),
                            child: Text(
                              'Gender',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                          // Gender radios
                          Row(
                            children: [
                              _genderTile('Male'),
                              _genderTile('Female'),
                            ],
                          ),

                          // Birthday with Calendar Picker
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _birthdayController,
                              readOnly: true,
                              decoration:
                                  _inputDecoration(
                                    'Birthday',
                                    hint: 'yyyy-mm-dd',
                                  ).copyWith(
                                    suffixIcon: Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              onTap: _selectBirthday,
                            ),
                          ),

                          // Address
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _addressController,
                              focusNode: _addressFocusNode,
                              readOnly:
                                  true,
                              onTap: _openMapPicker,
                              decoration: _inputDecoration(
                                'Address',
                                hint: 'Brgy 123 Phase 1 Purok 1',
                              ),
                            ),
                          ),

                          // Contact Number
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _contactController,
                              focusNode: _contactFocusNode,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration(
                                'Contact Number',
                                hint: '+63 912 345 6789',
                              ),
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

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedBirthday ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedBirthday) {
      setState(() {
        selectedBirthday = picked;
        _birthdayController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
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
        birthday: true,
        email: true,
      );

      if (!mounted) return;

      setState(() {
        _firstNameController.text = profile["firstName"]?.toString() ?? '';
        _lastNameController.text = profile["lastName"]?.toString() ?? '';
        _addressController.text = profile["address"]?.toString() ?? '';

        final birthdayStr = profile["birthday"]?.toString() ?? '';
        _birthdayController.text = birthdayStr;

        // Parse the birthday string to DateTime if it exists
        if (birthdayStr.isNotEmpty) {
          try {
            selectedBirthday = DateTime.parse(birthdayStr);
          } catch (e) {
            // If parsing fails, leave selectedBirthday as null
          }
        }

        _contactController.text = profile["contact"]?.toString() ?? '';
        selectedGender = profile["gender"]?.toString();

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

  Future<void> _handleSave() async {
    try {
      final result = await AuthService.updateUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: selectedGender ?? "male",
        contact: _contactController.text.trim(),
        address: _addressController.text.trim(),
        birthday: _birthdayController.text.trim(),
      );

      if (!mounted) return;

      if (result["success"] != true) {
        setState(() {
          isLoading = false;
          errorMessage = result["data"]?.toString() ?? 'Failed to load account';
        });
        return;
      }
      final user = User.fromJson(result["data"]);

      await PreferenceUtility.saveSession(
        user.id,
        user.email,
        user.firstName,
        user.lastName,
        user.gender,
        user.contact,
        user.address,
        user.birthday,
      );

      if (result["success"] == true) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load account: $e';
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

  Expanded _genderTile(String value) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(value, style: GoogleFonts.inter(fontSize: 14)),
        value: value,
        groupValue: selectedGender,
        onChanged: (v) => setState(() => selectedGender = v),
        dense: true,
        contentPadding: EdgeInsets.zero,
        activeColor: _primaryColor,
      ),
    );
  }
}
