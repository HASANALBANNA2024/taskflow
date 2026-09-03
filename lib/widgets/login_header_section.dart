import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFE5EDE6),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.edit_note_rounded,
            color: Color(0xFF335340),
            size: 38,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome back',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E2922),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'All your tasks in one place. Log in to\npick up where you left off.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF718096),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}