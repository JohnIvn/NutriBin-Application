import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:nutribin_application/services/auth_service.dart';

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
  final List<String> _previousValues = List.generate(6, (_) => '');

  bool _isLoading = false;
  String? _recipient;
  String? _userId;
  OtpVerificationType? _verificationType;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();

    // Add listeners to track previous values for backspace detection
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        _handleOtpChange(i);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        _recipient = args?['recipient'] ?? '';
        _userId = args?['userId'] ?? '';
        final typeString = args?['type'] ?? 'email';
        _verificationType = _parseVerificationType(typeString);
      });
    });
  }

  void _handleOtpChange(int index) {
    final currentValue = _otpControllers[index].text;
    final previousValue = _previousValues[index];

    // User typed a new digit
    if (currentValue.isNotEmpty && previousValue.isEmpty) {
      _previousValues[index] = currentValue;
      // Move to next field
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
    // User deleted (backspace on non-empty field)
    else if (currentValue.isEmpty && previousValue.isNotEmpty) {
      _previousValues[index] = '';
      // Stay on current field - don't move back
    }
    // User replaced a digit
    else if (currentValue.isNotEmpty &&
        previousValue.isNotEmpty &&
        currentValue != previousValue) {
      _previousValues[index] = currentValue;
      // Move to next field
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
  }

  OtpVerificationType _parseVerificationType(String type) {
    switch (type.toLowerCase()) {
      case 'sms':
        return OtpVerificationType.contact;
      case 'passwordreset':
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
        return Icons.phone_android_rounded;
      case OtpVerificationType.passwordReset:
        return Icons.lock_reset_rounded;
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
    return 'We have sent a 6-digit verification code to';
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

  void _handleVerifyOtp() {
    final otp = _getOtpCode();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    Navigator.pop(context, {'otp': otp, 'ok': true});
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
      Map<String, dynamic> result;

      switch (_verificationType) {
        case OtpVerificationType.email:
          result = await AuthUtility.sendEmailVerification(email: _recipient!);
          break;
        case OtpVerificationType.contact:
          result = await AuthUtility.sendContactVerification(
            contact: _recipient!,
          );
          break;
        default:
          result = {'ok': false, 'message': 'Unknown verification type'};
      }

      if (mounted) {
        if (result['ok'] == true) {
          setState(() {
            _userId = result['userId'] ?? _userId;
          });

          for (final controller in _otpControllers) {
            controller.clear();
          }
          _otpFocusNodes.first.requestFocus();

          _startCooldown(60);

          final message = _verificationType == OtpVerificationType.contact
              ? 'Verification code sent to your phone'
              : 'Verification code sent to your email';

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
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

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor = isDarkMode
        ? Colors.grey[400]
        : const Color(0xFF57636C);

    // Highlight Color: Lighter Green in Dark Mode for visibility
    final highlightColor = isDarkMode ? const Color(0xFF8FAE8F) : primaryColor;

    // Input Field Colors
    final inputFillColor = isDarkMode
        ? Theme.of(context).cardTheme.color
        : Colors.white;
    final inputBorderColor = isDarkMode
        ? Colors.white12
        : const Color(0xFFE0E3E7);
    final inputTextColor = isDarkMode ? Colors.white : const Color(0xFF101213);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textColor),
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
                    // Icon Bubble
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: highlightColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIcon(), size: 50, color: highlightColor),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      _getTitle(),
                      style: GoogleFonts.interTight(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      _getDescription(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMaskedRecipient(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: highlightColor,
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
                                  cursorColor: highlightColor,
                                  style: GoogleFonts.inter(
                                    fontSize: boxWidth * 0.45,
                                    fontWeight: FontWeight.w600,
                                    color: inputTextColor,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: inputFillColor,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: inputBorderColor,
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: highlightColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    // When tapping on a field, select all text for easy replacement
                                    _otpControllers[index]
                                        .selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          _otpControllers[index].text.length,
                                    );
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
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: primaryColor.withOpacity(
                            0.5,
                          ),
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
                            color: subTextColor,
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
                                  ? subTextColor
                                  : highlightColor,
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
