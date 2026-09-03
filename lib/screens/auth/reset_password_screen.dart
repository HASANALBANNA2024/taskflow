import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(email: widget.email, otp: widget.otp, newPassword: _password.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset. Please log in with your new password.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.mossTint,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.password_outlined, color: AppColors.moss, size: 26),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Set a new password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose a strong password you have not used before.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: AppColors.inkFaint, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (auth.errorMessage != null) InlineError(message: auth.errorMessage!),
                  AppTextField(
                    label: 'New password',
                    controller: _password,
                    obscure: true,
                    validator: (v) => (v == null || v.length < 4) ? 'At least 4 characters' : null,
                  ),
                  AppTextField(
                    label: 'Confirm password',
                    controller: _confirm,
                    obscure: true,
                    validator: (v) => v != _password.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 6),
                  AppButton(label: 'Reset password', onPressed: _submit, loading: auth.isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}