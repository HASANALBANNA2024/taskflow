import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _email.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      mobile: _mobile.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please log in.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create your account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('A few details and you are set to go.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8B9385), height: 1.5)),
                const SizedBox(height: 22),
                if (auth.errorMessage != null) InlineError(message: auth.errorMessage!),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'First name',
                        controller: _firstName,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Last name',
                        controller: _lastName,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                AppTextField(
                  label: 'Mobile number',
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.length < 6) ? 'Enter a valid number' : null,
                ),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  obscure: true,
                  validator: (v) => (v == null || v.length < 4) ? 'At least 4 characters' : null,
                ),
                const SizedBox(height: 6),
                AppButton(label: 'Create account', onPressed: _submit, loading: auth.isLoading),
                GhostLink(
                  text: 'Already have an account?',
                  actionText: 'Log in',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
