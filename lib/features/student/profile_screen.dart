import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D44) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.lightPurple,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'john.doe@school.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              context,
              Icons.person_outline,
              'Edit Profile',
              () {},
            ),
            _buildMenuItem(
              context,
              Icons.help_outline,
              'Help & Support',
              () {},
            ),
            _buildMenuItem(
              context,
              Icons.info_outline,
              'About',
              () {},
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              Icons.logout,
              'Logout',
              () {
                context.go('/');
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryPurple,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : AppTheme.textDark,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: AppTheme.textGrey,
            ),
      ),
    );
  }
}
