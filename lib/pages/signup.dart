import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _addressFocus.dispose();
    _signUpEmailFocus.dispose();
    _signUpPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    // Add your sign in logic here
    print('Sign In: ${_signInEmailController.text}');

    // Navigate to dashboard after successful sign in
    Navigator.pushNamed(context, '/dashboard');
  }

  void _handleSignUp() async {
    if (_signUpPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords don\'t match!')));
      return;
    }

    // Add your sign up logic here
    print('Sign Up: ${_signUpEmailController.text}');

    // Navigate to dashboard after successful sign up
    // Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _handleForgotPassword() {
    // Navigate to forgot password/camera page
    // Navigator.pushNamed(context, '/camera');
  }

  void _handleGoogleSignIn() {
    // Add Google sign in logic here
    print('Google Sign In');
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
                    alignment: const AlignmentDirectional(0, -1),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            0,
                            44,
                            0,
                            0,
                          ),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 602),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                              ),
                            ),
                            alignment: const AlignmentDirectional(-1, 0),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 602),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                16,
                                0,
                                16,
                                0,
                              ),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: const Alignment(-1, 0),
                                    child: TabBar(
                                      isScrollable: true,
                                      labelColor: const Color(0xFF101213),
                                      unselectedLabelColor: const Color(
                                        0xFF57636C,
                                      ),
                                      labelPadding: const EdgeInsets.all(16),
                                      labelStyle: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF101213),
                                        fontSize: 36,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      unselectedLabelStyle:
                                          GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF101213),
                                            fontSize: 36,
                                            fontWeight: FontWeight.normal,
                                          ),
                                      indicatorColor: _primaryColor,
                                      indicatorWeight: 4,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                            0,
                                            12,
                                            16,
                                            12,
                                          ),
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
    return Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
        child:
            Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        0,
                        12,
                        0,
                        24,
                      ),
                      child: Text(
                        'Let\'s get started by filling out the form below.',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF57636C),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildTextField(
                      controller: _signInEmailController,
                      focusNode: _signInEmailFocus,
                      label: 'Email',
                      autofocus: true,
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
                      alignment: const AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          0,
                          16,
                        ),
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
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          0,
                          16,
                        ),
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(230, 44),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Forgot Password',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF101213),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildSocialSignInSection(),
                  ],
                )
                .animate()
                .fadeIn(curve: Curves.easeInOut, duration: 300.ms)
                .moveY(
                  curve: Curves.easeInOut,
                  begin: 60,
                  end: 0,
                  duration: 300.ms,
                ),
      ),
    );
  }

  Widget _buildSignUpTab() {
    return Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
        child: SingleChildScrollView(
          child:
              Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          12,
                          0,
                          24,
                        ),
                        child: Text(
                          'Let\'s get started by filling out the form below.',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF57636C),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildTextField(
                        controller: _firstNameController,
                        focusNode: _firstNameFocus,
                        label: 'First Name',
                        autofocus: true,
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.givenName],
                      ),
                      _buildTextField(
                        controller: _lastNameController,
                        focusNode: _lastNameFocus,
                        label: 'Last Name',
                        autofocus: true,
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.familyName],
                      ),
                      _buildTextField(
                        controller: _addressController,
                        focusNode: _addressFocus,
                        label: 'Address',
                        autofocus: true,
                        keyboardType: TextInputType.streetAddress,
                        autofillHints: const [AutofillHints.fullStreetAddress],
                      ),
                      _buildTextField(
                        controller: _signUpEmailController,
                        focusNode: _signUpEmailFocus,
                        label: 'Email',
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            16,
                            2,
                            0,
                            2,
                          ),
                          child: Text(
                            'Gender:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          4,
                          0,
                          4,
                        ),
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
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
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
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            0,
                            0,
                            0,
                            16,
                          ),
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
                            child: Text(
                              'Create Account',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildSocialSignInSection(),
                    ],
                  )
                  .animate()
                  .fadeIn(curve: Curves.easeInOut, duration: 300.ms)
                  .moveY(
                    curve: Curves.easeInOut,
                    begin: 60,
                    end: 0,
                    duration: 300.ms,
                  ),
        ),
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
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
      child: SizedBox(
        width: double.infinity,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          autofillHints: autofillHints,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: const Color(0xFF4B39EF),
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF101213),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF57636C),
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
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return Expanded(
      child: SizedBox(
        height: 32,
        child: RadioListTile<String>(
          title: Text(value, style: GoogleFonts.inter(fontSize: 14)),
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
        ),
      ),
    );
  }

  Widget _buildSocialSignInSection() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            child: Text(
              'Or sign up with',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF57636C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 0,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.horizontal,
              runAlignment: WrapAlignment.center,
              verticalDirection: VerticalDirection.down,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: OutlinedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                    label: Text(
                      'Continue with Google',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF101213),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style:
                        OutlinedButton.styleFrom(
                          minimumSize: const Size(230, 44),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF101213),
                          side: const BorderSide(
                            color: Color(0xFFE0E3E7),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(
                            const Color(0xFFF1F4F8),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
