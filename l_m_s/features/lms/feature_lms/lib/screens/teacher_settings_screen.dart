import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/lms_theme.dart';
import '../theme/theme_mode_holder.dart';

/// Teacher settings: profile placeholder, theme toggle, notifications placeholder.
class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher-dashboard'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
              side: const BorderSide(color: LMSTheme.borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: const Text('Teacher'),
                    subtitle: Text('Manage name, email in Sanity or admin', style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
              side: const BorderSide(color: LMSTheme.borderColor),
            ),
            child: Column(
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeModeHolder.notifier,
                  builder: (context, mode, _) => SwitchListTile(
                    title: const Text('Dark mode'),
                    subtitle: const Text('Use dark theme across the app'),
                    value: mode == ThemeMode.dark,
                    onChanged: (_) => ThemeModeHolder.toggle(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
              side: const BorderSide(color: LMSTheme.borderColor),
            ),
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: Text('Preferences – coming soon', style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground)),
            ),
          ),
        ],
      ),
    );
  }
}
