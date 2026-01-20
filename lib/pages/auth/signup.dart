import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/models/user.dart';
import 'package:nutribin_application/services/auth_service.dart';
import 'package:nutribin_application/services/google_auth_service.dart';
import 'package:nutribin_application/utils/helpers.dart';
import 'package:nutribin_application/widgets/map_picker.dart';
import 'package:nutribin_application/widgets/terms_accept.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Sign In form controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  final _signInEmailFocus = FocusNode();
  final _signInPasswordFocus = FocusNode();
  bool _signInPasswordVisible = false;

  // Sign Up form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _birthdayFocus = FocusNode();
  DateTime? _selectedBirthday;

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _contactFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _signUpEmailFocus = FocusNode();
  final _signUpPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _passwordVisible = false;
  String? _selectedGender;
  bool _termsRead = false;
  bool _termsAccepted = false;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkExistingSession();

    _signUpPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signInEmailFocus.dispose();
    _signInPasswordFocus.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    _birthdayController.dispose();
    _birthdayFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _contactFocus.dispose();
    _addressFocus.dispose();
    _signUpEmailFocus.dispose();
    _signUpPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _navigateToTerms() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAcceptancePage()),
    );

    if (result != null && result is bool) {
      setState(() {
        _termsRead = result;
      });
      if (_termsRead == true) {
        _termsAccepted = result;
      }
    }
  }

  void _validatePassword() {
    final password = _signUpPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigit = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  bool _validateSignInForm() {
    if (_signInEmailController.text.trim().isEmpty) {
      _showError("Email is required");
      _signInEmailFocus.requestFocus();
      return false;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_signInEmailController.text.trim())) {
      _showError("Invalid email format");
      _signInEmailFocus.requestFocus();
      return false;
    }

    if (_signInPasswordController.text.isEmpty) {
      _showError("Password is required");
      _signInPasswordFocus.requestFocus();
      return false;
    }

    return true;
  }

  bool _validateSignUpForm() {
    if (_firstNameController.text.trim().isEmpty) {
      _showError("First name is required");
      _firstNameFocus.requestFocus();
      return false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      _showError("Last name is required");
      _lastNameFocus.requestFocus();
      return false;
    }

    if (_contactController.text.trim().isEmpty) {
      _showError("Contact number is required");
      _contactFocus.requestFocus();
      return false;
    }

    if (_contactController.text.trim().length < 10) {
      _showError("Contact number is invalid");
      _contactFocus.requestFocus();
      return false;
    }

    if (_addressController.text.trim().isEmpty) {
      _showError("Please select an address");
      _addressFocus.requestFocus();
      return false;
    }

    if (_birthdayController.text.trim().isEmpty) {
      _showError("Birthday is required");
      _birthdayFocus.requestFocus();
      return false;
    }

    final age = ProfileUtility.calculateAge(_birthdayController.text.trim());
    if (age < 18) {
      _showError("You must be at least 18 years old");
      _birthdayFocus.requestFocus();
      return false;
    }

    if (_selectedGender == null) {
      _showError("Please select a gender");
      return false;
    }

    if (_signUpEmailController.text.trim().isEmpty) {
      _showError("Email is required");
      _signUpEmailFocus.requestFocus();
      return false;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_signUpEmailController.text.trim())) {
      _showError("Invalid email format");
      _signUpEmailFocus.requestFocus();
      return false;
    }

    if (_signUpPasswordController.text.isEmpty) {
      _showError("Password is required");
      _signUpPasswordFocus.requestFocus();
      return false;
    }

    if (!_hasMinLength ||
        !_hasUppercase ||
        !_hasLowercase ||
        !_hasDigit ||
        !_hasSpecialChar) {
      _showError("Password does not meet all requirements");
      _signUpPasswordFocus.requestFocus();
      return false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showError("Please confirm your password");
      _confirmPasswordFocus.requestFocus();
      return false;
    }

    if (_signUpPasswordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      _confirmPasswordFocus.requestFocus();
      return false;
    }

    if (!_termsAccepted) {
      _showError("You must accept the Terms of Service");
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await GoogleOAuthService.signInWithGoogle();

      if (result['success'] != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Google sign in failed'),
            ),
          );
        }
        return;
      }

      final user = User.fromJson(result['user']);
      final isNewUser = result['isNewUser'] ?? false;
      final requiresEmailVerification =
          result['requiresEmailVerification'] ?? false;

      // Save session
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

      if (mounted) {
        if (requiresEmailVerification) {
          // Navigate to email verification
          final verificationResult = await Navigator.pushNamed(
            context,
            '/verify-otp',
            arguments: {
              'recipient': user.email,
              'type': 'email',
              'data': {'userId': user.id},
            },
          );

          if (verificationResult != null &&
              verificationResult is Map &&
              verificationResult['verified'] == true) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (isNewUser &&
            (user.contact == null || user.contact.isEmpty)) {
          // New Google user might need to complete profile (add contact)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome! Please complete your profile.'),
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Existing user, go to home
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Updated _handleSignUp to include email verification
  void _handleSignUpWithVerification() async {
    try {
      if (!_validateSignUpForm()) return;
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please accept the Terms of Service")),
        );
        return;
      }

      setState(() => _isLoading = true);

      final result = await AuthService.signup(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _selectedGender.toString(),
        contact: _contactController.text.trim(),
        address: _addressController.text.trim(),
        birthday: _birthdayController.text.trim(),
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (result["success"] != true) {
        throw Exception(result["message"] ?? "Signup failed");
      }

      final user = User.fromJson(result["user"]);

      // Save session
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

      if (mounted) {
        setState(() => _isLoading = false);

        // Navigate to email verification
        final verificationResult = await Navigator.pushNamed(
          context,
          '/verify-otp',
          arguments: {
            'recipient': user.email,
            'type': 'email',
            'data': {'userId': user.id},
          },
        );

        if (verificationResult != null &&
            verificationResult is Map &&
            verificationResult['verified'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  // Add this widget for the Google Sign In button
  Widget _buildGoogleSignInButton() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF57636C),
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
        ),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(230, 52),
              side: const BorderSide(color: Color(0xFFE0E3E7), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            icon: Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              'Continue with Google',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF101213),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSignIn() async {
    try {
      if (!_validateSignInForm()) return;
      final result = await AuthService.signin(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text.trim(),
      );

      if (result["success"] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Login failed")),
        );

        throw Error();
      }

      final user = User.fromJson(result["user"]);

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

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print(e);
    }
  }

  void _handleSignUp() async {
    try {
      if (!_validateSignUpForm()) return;
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please accept the Terms of Service")),
        );
        return;
      }

      if (_signUpPasswordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid Password")));
        return;
      }

      // Validate password requirements
      if (!_hasMinLength ||
          !_hasUppercase ||
          !_hasLowercase ||
          !_hasDigit ||
          !_hasSpecialChar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password does not meet all requirements"),
          ),
        );
        return;
      }

      final result = await AuthService.signup(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _selectedGender.toString(),
        contact: _contactController.text.trim(),
        address: _addressController.text.trim(),
        birthday: _birthdayController.text.trim(),
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (result["success"] != true) {
        throw Exception(result["message"] ?? "Signup failed");
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup successful")));

      final user = User.fromJson(result["user"]);

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

      Navigator.pushNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _handleForgotPassword() {
    // Navigate to forgot password/camera page
    Navigator.pushNamed(context, '/forgot-password');
  }

  void _openMapPicker() async {
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

  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: _secondaryBackground),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 8,
                  child: Container(
                    width: 100,
                    height: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 602),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: TabBar(
                                    isScrollable: false,
                                    labelColor: const Color(0xFF101213),
                                    unselectedLabelColor: const Color(
                                      0xFF57636C,
                                    ),
                                    labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF101213),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    unselectedLabelStyle: const TextStyle(
                                      color: Color(0xFF101213),
                                      fontSize: 28,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    indicatorColor: _primaryColor,
                                    indicatorWeight: 4,
                                    tabs: const [
                                      Tab(text: 'Sign In'),
                                      Tab(text: 'Sign Up'),
                                    ],
                                    controller: _tabController,
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildSignInTab(),
                                      _buildSignUpTab(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width > 768)
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: 100,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                            'https://images.unsplash.com/photo-1508385082359-f38ae991e8f2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80',
                          ),
                        ),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 12),
            child: Text(
              'Let\'s get started by filling out the form below.',
              style: const TextStyle(
                color: Color(0xFF57636C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          _buildTextField(
            controller: _signInEmailController,
            focusNode: _signInEmailFocus,
            label: 'Email',
            autofocus: false,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),

          _buildTextField(
            controller: _signInPasswordController,
            focusNode: _signInPasswordFocus,
            label: 'Password',
            obscureText: !_signInPasswordVisible,
            autofillHints: const [AutofillHints.password],
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  _signInPasswordVisible = !_signInPasswordVisible;
                });
              },
              focusNode: FocusNode(skipTraversal: true),
              child: Icon(
                _signInPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF57636C),
                size: 24,
              ),
            ),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.transparent,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF101213),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: ElevatedButton(
              onPressed: _handleSignIn,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: _primaryColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Google Sign In
          _buildGoogleSignInButton(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSignUpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 12),
            child: Text(
              'Let\'s get started by filling out the form below.',
              style: const TextStyle(
                color: Color(0xFF57636C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildTextField(
            controller: _firstNameController,
            focusNode: _firstNameFocus,
            label: 'First Name',
            autofocus: false,
            keyboardType: TextInputType.name,
            autofillHints: const [AutofillHints.givenName],
          ),
          _buildTextField(
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            label: 'Last Name',
            keyboardType: TextInputType.name,
            autofillHints: const [AutofillHints.familyName],
          ),
          // _buildTextField(
          //   controller: _contactController,
          //   focusNode: _contactFocus,
          //   label: 'Contact',
          //   keyboardType: TextInputType.number,
          //   autofillHints: const [AutofillHints.telephoneNumber],
          // ),
          _buildMapAddressField(
            controller: _addressController,
            focusNode: _addressFocus,
            label: 'Address',
            onTap: _openMapPicker,
          ),
          _buildDateField(
            controller: _birthdayController,
            focusNode: _birthdayFocus,
            label: 'Birthday',
            onTap: _pickBirthday,
          ),

          _buildTextField(
            controller: _signUpEmailController,
            focusNode: _signUpEmailFocus,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Text(
              'Gender:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _buildRadioOption('Male'),
                _buildRadioOption('Female'),
              ],
            ),
          ),
          _buildTextField(
            controller: _signUpPasswordController,
            focusNode: _signUpPasswordFocus,
            label: 'Password',
            obscureText: !_passwordVisible,
            autofillHints: const [AutofillHints.password],
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              focusNode: FocusNode(skipTraversal: true),
              child: Icon(
                _passwordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF57636C),
                size: 24,
              ),
            ),
          ),
          _buildPasswordRequirements(),
          _buildTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            label: 'Confirm Password',
            obscureText: !_passwordVisible,
            autofillHints: const [AutofillHints.password],
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              focusNode: FocusNode(skipTraversal: true),
              child: Icon(
                _passwordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF57636C),
                size: 24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _termsAccepted,
                    onChanged: (bool? value) {
                      if (_termsRead) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      } else {
                        // Show snackbar if terms not read
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please read the terms first.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    activeColor: _primaryColor,
                    checkColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF57636C),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: _primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _navigateToTerms,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              onPressed: _handleSignUpWithVerification, // Updated handler
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: _primaryColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password must contain:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF57636C),
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('At least 8 characters', _hasMinLength),
          _buildRequirementItem('Uppercase letter (A-Z)', _hasUppercase),
          _buildRequirementItem('Lowercase letter (a-z)', _hasLowercase),
          _buildRequirementItem('Number (0-9)', _hasDigit),
          _buildRequirementItem(
            'Special character (!@#\$%^&*)',
            _hasSpecialChar,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isMet ? Colors.green : Colors.red.shade300,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : const Color(0xFF57636C),
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    bool autofocus = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<String>? autofillHints,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        autofillHints: autofillHints,
        obscureText: obscureText,
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF4B39EF),
        style: const TextStyle(
          color: Color(0xFF101213),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF57636C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE0E3E7), width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _primaryColor, width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFF5963), width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFF5963), width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(24),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return Expanded(
      child: SizedBox(
        height: 32,
        child: RadioListTile<String>(
          title: Text(value, style: const TextStyle(fontSize: 13)),
          value: value,
          groupValue: _selectedGender,
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
          activeColor: _primaryColor,
          contentPadding: EdgeInsets.zero,
          dense: true,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Future<void> _pickBirthday() async {
    DateTime initialDate = DateTime(2000);
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        readOnly: true,
        onTap: onTap,
        cursorColor: const Color(0xFF4B39EF),
        style: const TextStyle(
          color: Color(0xFF101213),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF57636C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE0E3E7), width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _primaryColor, width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(24),
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF57636C),
          ),
        ),
      ),
    );
  }

  Widget _buildMapAddressField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        readOnly: true,
        onTap: onTap,
        cursorColor: const Color(0xFF4B39EF),
        style: const TextStyle(
          color: Color(0xFF101213),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF57636C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE0E3E7), width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _primaryColor, width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(24),
          suffixIcon: const Icon(
            Icons.location_on_outlined,
            color: Color(0xFF57636C),
          ),
        ),
      ),
    );
  }
}
