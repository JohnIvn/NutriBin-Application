import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class VerifyPasswordResetOtpPage extends StatefulWidget {
  const VerifyPasswordResetOtpPage({super.key});

  @override
  State<VerifyPasswordResetOtpPage> createState() =>
      _VerifyPasswordResetOtpPageState();
}

class _VerifyPasswordResetOtpPageState
    extends State<VerifyPasswordResetOtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _email;
  String? _userId;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  String? _expectedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        _email = args?['recipient'] ?? '';
        _userId = args?['userId'] ?? '';
        _expectedCode = args?['expectedCode'] ?? '';
      });
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _startCooldown([int seconds = 60]) {
    setState(() => _cooldownSeconds = seconds);

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() => _cooldownSeconds = 0);
        }
      } else {
        if (mounted) {
          setState(() => _cooldownSeconds--);
        }
      }
    });
  }

  String _getMaskedEmail() {
    if (_email == null || _email!.isEmpty) return '';

    if (_email!.contains('@')) {
      final parts = _email!.split('@');
      final username = parts[0];
      final domain = parts[1];
      if (username.length > 2) {
        return '${username.substring(0, 2)}***@$domain';
      }
    }
    return _email!;
  }

  void _handleVerifyOtp() async {
    final otp = _getOtpCode();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    // Check if expected code exists
    if (_expectedCode == null || _expectedCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification session expired. Please go back and try again.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Compare the entered OTP with the expected code
      if (otp == _expectedCode) {
        // result = {
        //   'success': true,
        //   'match': true,
        //   'message': 'Code verified successfully',
        //   'code': otp,
        // };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP Verified Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamed(
          context,
          '/reset-password',
          arguments: {"email": _email},
        );
      } else {
        // result = {
        //   'success': false,
        //   'match': false,
        //   'message': 'Invalid verification code',
        //   'code': otp,
        // };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP Verification Invalid"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleResendOtp() async {
    if (_email == null || _email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not found. Please go back.')),
      );
      return;
    }

    if (_cooldownSeconds > 0) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with real API call
      // result = await AuthService.sendPasswordResetOtp(email: _email!);

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      Map<String, dynamic> result = {
        'success': true,
        'message': 'Code sent successfully',
        'userId': _userId,
        'code':
            _expectedCode, // In production, this will be the new code from API
      };

      if (mounted) {
        if (result['success'] == true) {
          // Update userId and expected code from new response
          setState(() {
            _userId = result['userId'] ?? _userId;
            _expectedCode = result['code'] ?? result['expectedCode'] ?? '';
          });

          // Clear all OTP input fields
          for (final controller in _otpControllers) {
            controller.clear();
          }
          _otpFocusNodes.first.requestFocus();

          _startCooldown(60);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent to your email'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to resend code'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to resend code')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color get _primaryColor => Theme.of(context).primaryColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 50,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Verify Code',
                      style: GoogleFonts.interTight(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF101213),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      'We have sent a 6-digit verification code to',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMaskedEmail(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // OTP Input Fields
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final boxWidth = (constraints.maxWidth - (5 * 8)) / 6;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < 5 ? 8 : 0,
                              ),
                              child: SizedBox(
                                width: boxWidth,
                                height: boxWidth * 1.2,
                                child: TextFormField(
                                  controller: _otpControllers[index],
                                  focusNode: _otpFocusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: GoogleFonts.inter(
                                    fontSize: boxWidth * 0.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE0E3E7),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _otpFocusNodes[index + 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleVerifyOtp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: _primaryColor,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Verify Code',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Resend Code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code? ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF57636C),
                          ),
                        ),
                        TextButton(
                          onPressed: (_cooldownSeconds > 0 || _isLoading)
                              ? null
                              : _handleResendOtp,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _cooldownSeconds > 0
                                ? 'Resend in ${_cooldownSeconds}s'
                                : 'Resend',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _cooldownSeconds > 0
                                  ? const Color(0xFF57636C)
                                  : _primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
