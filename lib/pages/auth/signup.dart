import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutribin_application/services/auth_service.dart';

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
  final _addressController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _birthdayFocus = FocusNode();
  DateTime? _selectedBirthday;

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _signUpEmailFocus = FocusNode();
  final _signUpPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _signUpPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    _birthdayController.dispose();
    _birthdayFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _addressFocus.dispose();
    _signUpEmailFocus.dispose();
    _signUpPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    try {
      final result = await AuthService.signin(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text.trim(),
      );

      if (result["success"] != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result["data"].toString())));
        throw Error();
      }
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      print(e);
    }
  }

  void _handleSignUp() async {
    try {
      final result = await AuthService.signup(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        gender: _selectedGender.toString(),
        address: _addressController.text,
        birthday: _birthdayController.text,
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (_signUpPasswordController.text.trim() == '') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid Password")));
        return;
      }

      if (result["success"] != true) {
        throw Exception(result["data"]);
      }
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _handleForgotPassword() {
    // Navigate to forgot password/camera page
    // Navigator.pushNamed(context, '/camera');
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
                'Forgot Password',
                style: TextStyle(
                  color: Color(0xFF101213),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              onPressed: _handleSignIn,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(230, 52),
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
          _buildTextField(
            controller: _addressController,
            focusNode: _addressFocus,
            label: 'Address',
            keyboardType: TextInputType.streetAddress,
            autofillHints: const [AutofillHints.fullStreetAddress],
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
                _buildRadioOption('Others'),
              ],
            ),
          ),
          _buildTextField(
            controller: _signUpPasswordController,
            focusNode: _signUpPasswordFocus,
            label: 'Password',
            obscureText: !_signUpPasswordVisible,
            autofillHints: const [AutofillHints.password],
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  _signUpPasswordVisible = !_signUpPasswordVisible;
                });
              },
              focusNode: FocusNode(skipTraversal: true),
              child: Icon(
                _signUpPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF57636C),
                size: 24,
              ),
            ),
          ),
          _buildTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            label: 'Confirm Password',
            obscureText: !_confirmPasswordVisible,
            autofillHints: const [AutofillHints.password],
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              },
              focusNode: FocusNode(skipTraversal: true),
              child: Icon(
                _confirmPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF57636C),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              onPressed: _handleSignUp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(230, 52),
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
}
