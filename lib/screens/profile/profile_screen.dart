import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final counts = context.watch<TaskProvider>().counts;
    final user = auth.currentUser;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 46),
            decoration: const BoxDecoration(
              color: AppColors.moss,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  child: Text(user?.initials ?? '?',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.moss)),
                ),
                const SizedBox(height: 10),
                Text(
                    user?.fullName.trim().isNotEmpty == true
                        ? user!.fullName
                        : 'Your name',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(user?.email ?? '',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.line),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 20,
                      offset: Offset(0, 12))
                ],
              ),
              child: Row(
                children: [
                  _stat('${counts.total}', 'Total'),
                  _divider(),
                  _stat('${counts.newCount}', 'New'),
                  _divider(),
                  _stat('${counts.completedCount}', 'Completed'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                _menuRow(
                  icon: Icons.person_outline,
                  label: 'Edit profile',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const EditProfileScreen())),
                ),
                _menuRow(
                  icon: Icons.lock_outline,
                  label: 'Change password',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Use forgot password option to reset/change password.')),
                    );
                  },
                ),
                _menuRow(
                    icon: Icons.notifications_none,
                    label: 'Notifications',
                    onTap: () {}),
                _menuRow(
                  icon: Icons.logout,
                  label: 'Log out',
                  danger: true,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String n, String l) => Expanded(
        child: Column(
          children: [
            Text(n,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(l,
                style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.inkFaint,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _divider() => Container(width: 1, height: 30, color: AppColors.line);

  Widget _menuRow(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool danger = false}) {
    final color = danger ? AppColors.brick : AppColors.ink;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: danger ? AppColors.brickTint : AppColors.chipNeutral,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: color))),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.inkFaint),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Log out?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text("You'll need to log in again to see your tasks."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log out',
                style: TextStyle(
                    color: AppColors.brick, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
