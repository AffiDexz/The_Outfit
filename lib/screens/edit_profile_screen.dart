// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey     = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _zipCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameCtrl    = TextEditingController(text: user?.fullName ?? '');
    _emailCtrl   = TextEditingController(text: user?.email ?? '');
    _phoneCtrl   = TextEditingController(text: user?.phone ?? '');
    _addressCtrl = TextEditingController(text: user?.address ?? '');
    _cityCtrl    = TextEditingController(text: user?.city ?? '');
    _zipCtrl     = TextEditingController(text: user?.zip ?? '');
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl,
                     _addressCtrl, _cityCtrl, _zipCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    context.read<UserProvider>().updateProfile(
      fullName: _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
      address:  _addressCtrl.text.trim(),
      city:     _cityCtrl.text.trim(),
      zip:      _zipCtrl.text.trim(),
    );
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.accent),
            SizedBox(width: 10),
            Text('Profile updated successfully!',
                style: TextStyle(color: AppColors.white)),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Consumer<UserProvider>(
                      builder: (_, prov, __) => Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent, width: 2),
                          color: AppColors.surface,
                        ),
                        child: Center(
                          child: Text(
                            prov.user?.initials ?? '?',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
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
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ── Personal info ──────────────────────────────────────────────
              _sectionHeader('Personal Information'),
              const SizedBox(height: 14),
              _field(_nameCtrl,  'Full Name',     Icons.person_outline,
                  validator: (v) => v == null || v.trim().length < 2 ? 'Enter your name' : null),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email Address', Icons.email_outlined,
                  type: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone Number',  Icons.phone_outlined,
                  type: TextInputType.phone),

              const SizedBox(height: 24),

              // ── Address ────────────────────────────────────────────────────
              _sectionHeader('Delivery Address'),
              const SizedBox(height: 14),
              _field(_addressCtrl, 'Street Address', Icons.location_on_outlined),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field(_cityCtrl, 'City', Icons.location_city_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_zipCtrl, 'ZIP Code', Icons.pin_drop_outlined,
                      type: TextInputType.number)),
                ],
              ),

              const SizedBox(height: 36),
              CustomButton(
                label:    'SAVE CHANGES',
                onTap:    _save,
                isLoading: _saving,
                width:    double.infinity,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator,
      );
}