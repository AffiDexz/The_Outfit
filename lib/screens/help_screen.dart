// lib/screens/help_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expanded;

  static const _faqs = [
    {
      'q': 'How do I track my order?',
      'a': 'Once your order is shipped, you can track it from the My Orders screen under your Profile. A tracking ID will be shown on each shipped order.',
    },
    {
      'q': 'What is the return policy?',
      'a': 'We accept returns within 30 days of delivery. Items must be in their original condition with tags attached. Visit our website or contact support to initiate a return.',
    },
    {
      'q': 'How do I change my delivery address?',
      'a': 'You can update your delivery address from the Edit Profile screen. Changes will apply to future orders.',
    },
    {
      'q': 'Can I cancel my order?',
      'a': 'Orders can be cancelled within 1 hour of placement if they have not yet been processed for shipping. Go to My Orders and tap Cancel on the relevant order.',
    },
    {
      'q': 'How do I apply a discount code?',
      'a': 'Discount code functionality will be available in a future update. Stay tuned for promotional offers via email and app notifications.',
    },
    {
      'q': 'What payment methods are accepted?',
      'a': 'We accept major credit/debit cards (Visa, Mastercard, Amex), PayPal, and Apple Pay.',
    },
  ];

  // FIX: show "Coming Soon" snackbar for contact buttons
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.schedule_rounded, color: AppColors.accent, size: 18),
            const SizedBox(width: 10),
            Text(
              '$feature — Coming Soon',
              style: const TextStyle(color: AppColors.white, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Help & Support'),
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
            // ── Contact card ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withAlpha(51),
                    AppColors.accent.withAlpha(13),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withAlpha(77)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need help?',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Our team is available Mon–Fri, 9am–6pm EST.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // FIX: Email Us — now tappable with Coming Soon feedback
                      _contactChip(
                        icon: Icons.email_outlined,
                        label: 'Email Us',
                        onTap: () => _showComingSoon('Email Support'),
                      ),
                      const SizedBox(width: 10),
                      // FIX: Live Chat — now tappable with Coming Soon feedback
                      _contactChip(
                        icon: Icons.chat_bubble_outline,
                        label: 'Live Chat',
                        onTap: () => _showComingSoon('Live Chat'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── FAQ ──────────────────────────────────────────────────────────
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            ..._faqs.asMap().entries.map((e) {
              final i   = e.key;
              final faq = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ExpansionTile(
                  key: Key('faq_$i'),
                  initiallyExpanded: _expanded == i,
                  onExpansionChanged: (v) =>
                      setState(() => _expanded = v ? i : null),
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  collapsedIconColor: AppColors.textMuted,
                  iconColor: AppColors.accent,
                  title: Text(
                    faq['q']!,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faq['a']!,
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            height: 1.6),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // FIX: _contactChip now accepts onTap callback — was a static Container before
  Widget _contactChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      );
}
