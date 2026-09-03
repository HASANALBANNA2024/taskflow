import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: _user?.firstName ?? '');
  late final _lastName = TextEditingController(text: _user?.lastName ?? '');
  late final _mobile = TextEditingController(text: _user?.mobile ?? '');
  late final _email = TextEditingController(text: _user?.email ?? '');

  get _user => context.read<AuthProvider>().currentUser;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      mobile: _mobile.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated.')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(bottom: 22),
                    decoration: BoxDecoration(
                        color: AppColors.mossTint,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    child: Text(user?.initials ?? '?',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mossDeep)),
                  ),
                ),
                if (auth.errorMessage != null)
                  InlineError(message: auth.errorMessage!),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'First name',
                        controller: _firstName,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Last name',
                        controller: _lastName,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                AppTextField(
                  label: 'Email (cannot be changed here)',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                AppTextField(
                  label: 'Mobile number',
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Enter a valid number'
                      : null,
                ),
                const SizedBox(height: 6),
                AppButton(
                    label: 'Save changes',
                    onPressed: _submit,
                    loading: auth.isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
