import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
          const SizedBox(height: 7),
          TextFormField(
            controller: widget.controller,
            obscureText: _obscured,
            keyboardType: widget.keyboardType,
            maxLines: widget.obscure ? 1 : widget.maxLines,
            validator: widget.validator,
            style: const TextStyle(fontSize: 13.5, color: AppColors.ink, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: widget.hint,
              suffixIcon: widget.obscure
                  ? IconButton(
                      icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 19, color: AppColors.inkFaint),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final bool danger;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 18, width: 18,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
        : Text(label);

    if (outlined) {
      return OutlinedButton(onPressed: loading ? null : onPressed, child: child);
    }
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: danger ? ElevatedButton.styleFrom(backgroundColor: AppColors.brick) : null,
      child: child,
    );
  }
}

class GhostLink extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;
  const GhostLink({super.key, required this.text, required this.actionText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12.5, color: AppColors.inkFaint, fontWeight: FontWeight.w600),
              children: [
                TextSpan(text: '$text '),
                TextSpan(
                  text: actionText,
                  style: const TextStyle(color: AppColors.moss, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.chipNeutral, borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, size: 28, color: AppColors.inkFaint),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: AppColors.inkFaint, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class InlineError extends StatelessWidget {
  final String message;
  const InlineError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(color: AppColors.brickTint, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 17, color: AppColors.brick),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 12, color: AppColors.brick, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
