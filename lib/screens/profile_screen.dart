// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final wishlist = context.watch<WishlistProvider>();

    final displayName = userProv.user?.fullName ?? 'Guest User';
    final email       = userProv.user?.email    ?? '';
    final initials    = userProv.user?.initials  ?? 'G';

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile header ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.accent, width: 2),
                          color: AppColors.cardBg,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.editProfile),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: AppColors.primary, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(email,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  // Dynamic stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                          value: '${userProv.orderCount}',
                          label: 'Orders'),
                      const _VDivider(),
                      _StatItem(
                          value: '${wishlist.count}',
                          label: 'Wishlist'),
                      const _VDivider(),
                      _StatItem(
                          value: '${userProv.reviewCount}',
                          label: 'Reviews'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ── My Shopping ────────────────────────────────────────────
                  _MenuSection(
                    title: 'My Shopping',
                    items: [
                      _MenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'My Orders',
                        subtitle: 'View your order history',
                        onTap: () {
                          final orders = context.read<UserProvider>().orders;
                          if (orders.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        color: AppColors.accent),
                                    SizedBox(width: 10),
                                    Text('No orders yet',
                                        style: TextStyle(
                                            color: AppColors.white)),
                                  ],
                                ),
                                backgroundColor: AppColors.surface,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            Navigator.pushNamed(context, AppRoutes.orders);
                          }
                        },
                      ),
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'Wishlist',
                        subtitle: '${wishlist.count} saved item(s)',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.wishlist),
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Saved Addresses',
                        subtitle: 'Manage delivery addresses',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.editProfile),
                      ),
                      _MenuItem(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment Methods',
                        subtitle: 'Cards & wallets',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.paymentMethods),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Account ────────────────────────────────────────────────
                  _MenuSection(
                    title: 'Account',
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your information',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.editProfile),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage alerts',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.settings),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle: 'App preferences',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.settings),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'FAQs and contact',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.help),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Logout ─────────────────────────────────────────────────
                  GestureDetector(
                    onTap: () => _confirmLogout(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(26),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.error.withAlpha(77)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'The Outfit  v1.0.0',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(color: AppColors.white)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().logout();
              Navigator.of(context).popUntil((r) => r.isFirst);
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Log Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
        ],
      );
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.divider);
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      const Divider(
                          height: 1,
                          color: AppColors.divider,
                          indent: 56),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        )),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      );
}
