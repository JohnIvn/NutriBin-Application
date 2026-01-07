import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountEditWidget extends StatefulWidget {
  const AccountEditWidget({super.key});

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
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController birthdayController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  
  // Focus nodes
  late FocusNode firstNameFocusNode;
  late FocusNode lastNameFocusNode;
  late FocusNode birthdayFocusNode;
  late FocusNode addressFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode confirmPasswordFocusNode;
  
  // Form state
  String? selectedGender;
  bool showPassword = true;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    birthdayController = TextEditingController();
    addressController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    
    // Initialize focus nodes
    firstNameFocusNode = FocusNode();
    lastNameFocusNode = FocusNode();
    birthdayFocusNode = FocusNode();
    addressFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Dispose controllers
    firstNameController.dispose();
    lastNameController.dispose();
    birthdayController.dispose();
    addressController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    
    // Dispose focus nodes
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    birthdayFocusNode.dispose();
    addressFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
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
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name Field
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: firstNameController,
                        focusNode: firstNameFocusNode,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                    
                    // Last Name Field
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: lastNameController,
                        focusNode: lastNameFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                    
                    // Gender Label
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
                    
                    // Gender Radio Buttons
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'Male',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: selectedGender == 'Male' 
                                    ? Colors.grey[600] 
                                    : Colors.grey[600],
                              ),
                            ),
                            value: 'Male',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: _primaryColor,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'Female',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: selectedGender == 'Female' 
                                    ? Colors.grey[600] 
                                    : Colors.grey[600],
                              ),
                            ),
                            value: 'Female',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: _primaryColor,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'Others',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: selectedGender == 'Others' 
                                    ? Colors.grey[600] 
                                    : Colors.grey[600],
                              ),
                            ),
                            value: 'Others',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                    
                    // Birthday Field
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: birthdayController,
                        focusNode: birthdayFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Birthday',
                          hintText: '1-6-2008',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFDBE2E7),
                        ),
                      ),
                    ),
                    
                    // Address Field
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: addressController,
                        focusNode: addressFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          hintText: 'Brgy 123 Phase 1 Purok 1 Fake City',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFDBE2E7),
                        ),
                      ),
                    ),
                    
                    // Email Field
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: emailController,
                        focusNode: emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'user123@example.com',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFDBE2E7),
                        ),
                      ),
                    ),
                    
                    // Password Field
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: passwordController,
                        focusNode: passwordFocusNode,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: '@User123',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFDBE2E7),
                        ),
                      ),
                    ),
                    
                    // Confirm Password Field
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: confirmPasswordController,
                        focusNode: confirmPasswordFocusNode,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: '@User123',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFDBE2E7),
                        ),
                      ),
                    ),
                    
                    // Show Password Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: showPassword,
                          onChanged: (value) {
                            setState(() {
                              showPassword = value ?? true;
                            });
                          },
                          activeColor: _primaryColor,
                          checkColor: Colors.white,
                          side: BorderSide(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        Text(
                          'Show Password',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Save Changes Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(270, 50),
                    padding: EdgeInsets.zero,
                    elevation: 3,
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
}