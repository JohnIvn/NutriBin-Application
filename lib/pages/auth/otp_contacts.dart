import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

enum OtpVerificationType { email, contact, passwordReset }

class ContactsVerification extends StatefulWidget {
  const ContactsVerification({super.key});

  @override
  State<ContactsVerification> createState() => _ContactsVerificationState();
}

class _ContactsVerificationState extends State<ContactsVerification> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _recipient; // Email or contact number
  OtpVerificationType? _verificationType;
  Map<String, dynamic>? _additionalData;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        _recipient = args?['recipient'] ?? '';
        final typeString = args?['type'] ?? 'email';
        _verificationType = _parseVerificationType(typeString);
        _additionalData = args?['data'];
      });
    });
  }

  OtpVerificationType _parseVerificationType(String type) {
    switch (type.toLowerCase()) {
      case 'contact':
      case 'phone':
        return OtpVerificationType.contact;
      case 'passwordreset':
      case 'password_reset':
        return OtpVerificationType.passwordReset;
      default:
        return OtpVerificationType.email;
    }
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

  IconData _getIcon() {
    switch (_verificationType) {
      case OtpVerificationType.contact:
        return Icons.phone_android;
      case OtpVerificationType.passwordReset:
        return Icons.lock_reset;
      default:
        return Icons.email_outlined;
    }
  }

  String _getTitle() {
    switch (_verificationType) {
      case OtpVerificationType.contact:
        return 'Verify Phone Number';
      case OtpVerificationType.passwordReset:
        return 'Verify Code';
      default:
        return 'Verify Email';
    }
  }

  String _getDescription() {
    switch (_verificationType) {
      case OtpVerificationType.contact:
        return 'We have sent a 6-digit verification code to';
      case OtpVerificationType.passwordReset:
        return 'We have sent a 6-digit verification code to';
      default:
        return 'We have sent a 6-digit verification code to';
    }
  }

  String _getMaskedRecipient() {
    if (_recipient == null || _recipient!.isEmpty) return '';

    if (_verificationType == OtpVerificationType.contact) {
      // Mask phone: +63 9XX XXX XX45
      if (_recipient!.length > 4) {
        final last4 = _recipient!.substring(_recipient!.length - 4);
        final prefix = _recipient!.substring(0, 3);
        return '$prefix XXXX XXX $last4';
      }
    } else {
      // Mask email: ex***@gmail.com
      if (_recipient!.contains('@')) {
        final parts = _recipient!.split('@');
        final username = parts[0];
        final domain = parts[1];
        if (username.length > 2) {
          return '${username.substring(0, 2)}***@$domain';
        }
      }
    }
    return _recipient!;
  }

  void _handleVerifyOtp() async {
    final otp = _getOtpCode();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual API calls
      // switch (_verificationType) {
      //   case OtpVerificationType.email:
      //     await AuthService.verifyEmail(email: _recipient, otp: otp);
      //     break;
      //   case OtpVerificationType.contact:
      //     await AuthService.verifyContact(contact: _recipient, otp: otp);
      //     break;
      //   case OtpVerificationType.passwordReset:
      //     await AuthService.verifyPasswordResetOtp(email: _recipient, otp: otp);
      //     break;
      // }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        switch (_verificationType) {
          case OtpVerificationType.email:
            // Email verified, proceed to home or next step
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email verified successfully!')),
            );
            Navigator.pushReplacementNamed(context, '/home');
            break;

          case OtpVerificationType.contact:
            // Contact verified, proceed to next step
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phone number verified successfully!'),
              ),
            );
            Navigator.pop(context, {'verified': true, 'otp': otp});
            break;

          case OtpVerificationType.passwordReset:
            // Navigate to reset password page
            Navigator.pushReplacementNamed(
              context,
              '/reset-password',
              arguments: {'email': _recipient, 'otp': otp},
            );
            break;

          default:
            Navigator.pop(context, {'verified': true, 'otp': otp});
        }
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
    if (_recipient == null || _recipient!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipient not found. Please go back.')),
      );
      return;
    }

    if (_cooldownSeconds > 0) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with real API calls
      // switch (_verificationType) {
      //   case OtpVerificationType.email:
      //     await AuthService.resendEmailOtp(email: _recipient!);
      //     break;
      //   case OtpVerificationType.contact:
      //     await AuthService.resendContactOtp(contact: _recipient!);
      //     break;
      //   case OtpVerificationType.passwordReset:
      //     await AuthService.resendPasswordResetOtp(email: _recipient!);
      //     break;
      // }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      for (final controller in _otpControllers) {
        controller.clear();
      }
      _otpFocusNodes.first.requestFocus();

      _startCooldown(60);

      if (mounted) {
        final message = _verificationType == OtpVerificationType.contact
            ? 'Verification code sent to your phone'
            : 'Verification code sent to your email';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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
                      child: Icon(_getIcon(), size: 50, color: _primaryColor),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      _getTitle(),
                      style: GoogleFonts.interTight(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF101213),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      _getDescription(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMaskedRecipient(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 50,
                          height: 60,
                          margin: EdgeInsets.only(right: index < 5 ? 12 : 0),
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF101213),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E3E7),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _otpFocusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _otpFocusNodes[index - 1].requestFocus();
                              }

                              // Auto-verify when all fields are filled
                              if (index == 5 && value.isNotEmpty) {
                                final allFilled = _otpControllers.every(
                                  (c) => c.text.isNotEmpty,
                                );
                                if (allFilled) {
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            },
                          ),
                        );
                      }),
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
