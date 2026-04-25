// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Appearance ──────────────────────────────────────────────────
            _sectionLabel('Appearance'),
            const SizedBox(height: 12),
            _settingsCard([
              _SwitchTile(
                icon:      Icons.dark_mode_outlined,
                title:     'Dark Mode',
                subtitle:  'Use dark theme throughout the app',
                value:     settings.darkMode,
                onChanged: (_) => settings.toggleDarkMode(),
              ),
            ]),

            const SizedBox(height: 24),

            // ── Notifications ────────────────────────────────────────────────
            _sectionLabel('Notifications'),
            const SizedBox(height: 12),
            _settingsCard([
              _SwitchTile(
                icon:      Icons.notifications_outlined,
                title:     'Push Notifications',
                subtitle:  'Receive alerts on your device',
                value:     settings.notifications,
                onChanged: (_) => settings.toggleNotifications(),
              ),
              _divider(),
              _SwitchTile(
                icon:      Icons.email_outlined,
                title:     'Email Updates',
                subtitle:  'Get newsletters and promotions',
                value:     settings.emailUpdates,
                onChanged: (_) => settings.toggleEmailUpdates(),
              ),
              _divider(),
              _SwitchTile(
                icon:      Icons.receipt_long_outlined,
                title:     'Order Alerts',
                subtitle:  'Track your orders in real-time',
                value:     settings.orderAlerts,
                onChanged: (_) => settings.toggleOrderAlerts(),
              ),
            ]),

            const SizedBox(height: 24),

            // ── Account ──────────────────────────────────────────────────────
            _sectionLabel('Account'),
            const SizedBox(height: 12),
            _settingsCard([
              _ActionTile(
                icon:     Icons.person_outline,
                title:    'Edit Profile',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editProfile),
              ),
              _divider(),
              _ActionTile(
                icon:     Icons.lock_outline,
                title:    'Change Password',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.changePassword),
              ),
              _divider(),
              // Language dropdown
              _DropdownTile(
                icon:     Icons.language_outlined,
                title:    'Language',
                value:    settings.language,
                items:    SettingsProvider.languages,
                onChanged: settings.setLanguage,
              ),
              _divider(),
              // Currency dropdown
              _DropdownTile(
                icon:     Icons.attach_money_rounded,
                title:    'Currency',
                value:    settings.currency,
                items:    SettingsProvider.currencies,
                onChanged: settings.setCurrency,
              ),
            ]),

            const SizedBox(height: 24),

            // ── Support ──────────────────────────────────────────────────────
            _sectionLabel('Support'),
            const SizedBox(height: 12),
            _settingsCard([
              _ActionTile(
                icon:  Icons.help_outline_rounded,
                title: 'Help Center',
                onTap: () => Navigator.pushNamed(context, AppRoutes.help),
              ),
              _divider(),
              _ActionTile(icon: Icons.privacy_tip_outlined,  title: 'Privacy Policy',   onTap: () {}),
              _divider(),
              _ActionTile(icon: Icons.description_outlined,  title: 'Terms of Service', onTap: () {}),
              _divider(),
              _ActionTile(icon: Icons.star_outline_rounded,  title: 'Rate the App',     onTap: () {}),
            ]),

            const SizedBox(height: 24),

            // ── Logout ───────────────────────────────────────────────────────
            GestureDetector(
              onTap: () {
                context.read<UserProvider>().logout();
                Navigator.of(context).popUntil((r) => r.isFirst);
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(26),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.error.withAlpha(77)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 18),
                    SizedBox(width: 10),
                    Text('Log Out',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text('The Outfit  v1.0.0  •  Phase 1',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────
Widget _sectionLabel(String text) => Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );

// ── Settings card container ───────────────────────────────────────────────────
Widget _settingsCard(List<Widget> children) => Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );

Widget _divider() =>
    const Divider(height: 1, color: AppColors.divider, indent: 56);

// ── Switch tile ───────────────────────────────────────────────────────────────
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) return AppColors.accent;
                return AppColors.textMuted;
              }),
              trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) return AppColors.accent.withValues(alpha: 0.3);
                return AppColors.divider;
              }),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      );
}

// ── Action tile ───────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _iconBox(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      );
}

// ── Dropdown tile ─────────────────────────────────────────────────────────────
class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
            ),
            DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.surface,
              underline: const SizedBox(),
              icon: const Icon(Icons.expand_more_rounded,
                  color: AppColors.textMuted, size: 18),
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
              items: items
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ],
        ),
      );
}

Widget _iconBox(IconData icon) => Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.accent, size: 18),
    );