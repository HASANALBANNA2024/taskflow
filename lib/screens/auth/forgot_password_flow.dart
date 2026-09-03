// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/theme.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/common_widgets.dart';
// import 'login_screen.dart';
//
// /// Step 1 — GET /RecoverVerifyEmail/:email
// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});
//
//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _email = TextEditingController();
//
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     final auth = context.read<AuthProvider>();
//     final ok = await auth.requestOtp(_email.text.trim());
//     if (!mounted) return;
//     if (ok) {
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (_) => OtpVerifyScreen(email: _email.text.trim())),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//     return Scaffold(
//       appBar: AppBar(),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 22),
//           child: Form(
//             key: _formKey,
//             child: _CenteredStep(
//               icon: Icons.mail_outline,
//               title: 'Forgot your password?',
//               subtitle: 'Enter your email and we will send you a verification code.',
//               child: Column(
//                 children: [
//                   if (auth.errorMessage != null) InlineError(message: auth.errorMessage!),
//                   AppTextField(
//                     label: 'Email',
//                     controller: _email,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
//                   ),
//                   const SizedBox(height: 6),
//                   AppButton(label: 'Send code', onPressed: _submit, loading: auth.isLoading),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Step 2 — GET /RecoverVerifyOtp/:email/:otp
// class OtpVerifyScreen extends StatefulWidget {
//   final String email;
//   const OtpVerifyScreen({super.key, required this.email});
//
//   @override
//   State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
// }
//
// class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _otp = TextEditingController();
//
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     final auth = context.read<AuthProvider>();
//     final ok = await auth.verifyOtp(email: widget.email, otp: _otp.text.trim());
//     if (!mounted) return;
//     if (ok) {
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: widget.email, otp: _otp.text.trim())),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//     return Scaffold(
//       appBar: AppBar(),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 22),
//           child: Form(
//             key: _formKey,
//             child: _CenteredStep(
//               icon: Icons.lock_clock_outlined,
//               title: 'Enter the code',
//               subtitle: 'We sent a verification code to ${widget.email}',
//               child: Column(
//                 children: [
//                   if (auth.errorMessage != null) InlineError(message: auth.errorMessage!),
//                   AppTextField(
//                     label: 'Verification code',
//                     controller: _otp,
//                     keyboardType: TextInputType.number,
//                     hint: '6-digit code',
//                     validator: (v) => (v == null || v.isEmpty) ? 'Enter the code' : null,
//                   ),
//                   const SizedBox(height: 6),
//                   AppButton(label: 'Verify', onPressed: _submit, loading: auth.isLoading),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Step 3 — POST /RecoverResetPassword
// class ResetPasswordScreen extends StatefulWidget {
//   final String email;
//   final String otp;
//   const ResetPasswordScreen({super.key, required this.email, required this.otp});
//
//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }
//
// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _password = TextEditingController();
//   final _confirm = TextEditingController();
//
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     final auth = context.read<AuthProvider>();
//     final ok = await auth.resetPassword(email: widget.email, otp: widget.otp, newPassword: _password.text);
//     if (!mounted) return;
//     if (ok) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Password reset. Please log in with your new password.')),
//       );
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//     return Scaffold(
//       appBar: AppBar(),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 22),
//           child: Form(
//             key: _formKey,
//             child: _CenteredStep(
//               icon: Icons.password_outlined,
//               title: 'Set a new password',
//               subtitle: 'Choose a strong password you have not used before.',
//               child: Column(
//                 children: [
//                   if (auth.errorMessage != null) InlineError(message: auth.errorMessage!),
//                   AppTextField(
//                     label: 'New password',
//                     controller: _password,
//                     obscure: true,
//                     validator: (v) => (v == null || v.length < 4) ? 'At least 4 characters' : null,
//                   ),
//                   AppTextField(
//                     label: 'Confirm password',
//                     controller: _confirm,
//                     obscure: true,
//                     validator: (v) => v != _password.text ? 'Passwords do not match' : null,
//                   ),
//                   const SizedBox(height: 6),
//                   AppButton(label: 'Reset password', onPressed: _submit, loading: auth.isLoading),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _CenteredStep extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final Widget child;
//   const _CenteredStep({required this.icon, required this.title, required this.subtitle, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           const SizedBox(height: 16),
//           Container(
//             width: 56, height: 56,
//             decoration: BoxDecoration(color: AppColors.mossTint, borderRadius: BorderRadius.circular(18)),
//             child: Icon(icon, color: AppColors.moss, size: 26),
//           ),
//           const SizedBox(height: 18),
//           Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
//           const SizedBox(height: 8),
//           Text(subtitle,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 12.5, color: AppColors.inkFaint, height: 1.5)),
//           const SizedBox(height: 24),
//           child,
//         ],
//       ),
//     );
//   }
// }
