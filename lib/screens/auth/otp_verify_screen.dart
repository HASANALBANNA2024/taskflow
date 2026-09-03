import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import 'reset_password_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final otp = _otpCode;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(email: widget.email, otp: otp);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email, otp: otp),
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.requestOtp(widget.email);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.mossTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.moss, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 13.5, color: AppColors.inkFaint, height: 1.5),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                    const TextSpan(text: ' — A 6-digit code has been sent'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (auth.errorMessage != null) InlineError(message: auth.errorMessage!),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 46,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.mossTint.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _focusNodes[index].hasFocus ? AppColors.moss : Colors.black12,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_otpCode.length == 6) {
                          _submit();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              AppButton(label: 'Verify', onPressed: _submit, loading: auth.isLoading),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: auth.isLoading ? null : _resendCode,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: AppColors.inkFaint),
                    children: [
                      TextSpan(text: "Didn't receive code? "),
                      TextSpan(
                        text: 'Resend',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.moss),
                      ),
                    ],
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