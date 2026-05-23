// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureP     = true;
  bool _obscureC     = true;
  bool _agree        = false;

  late AnimationController _fadeCtrl;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please agree to Terms & Conditions'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    final success = await context.read<UserProvider>().register(
      fullName: _nameCtrl.text,
      email:    _emailCtrl.text,
      password: _passCtrl.text,
      phone:    _phoneCtrl.text,
    );
    if (!mounted) return;
    if (success) Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Join The Outfit',
                      style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Create your account to start shopping',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 32),

                  _field(controller: _nameCtrl,  label: 'Full Name',     icon: Icons.person_outline,
                      validator: (v) => v == null || v.length < 2 ? 'Enter your name' : null),
                  const SizedBox(height: 14),
                  _field(controller: _emailCtrl, label: 'Email Address', icon: Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null),
                  const SizedBox(height: 14),
                  _field(controller: _phoneCtrl, label: 'Phone Number',  icon: Icons.phone_outlined,
                      type: TextInputType.phone),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscureP,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureP ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textMuted),
                        onPressed: () => setState(() => _obscureP = !_obscureP),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureC,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureC ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textMuted),
                        onPressed: () => setState(() => _obscureC = !_obscureC),
                      ),
                    ),
                    validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _agree,
                        onChanged: (v) => setState(() => _agree = v ?? false),
                        activeColor: AppColors.accent,
                        checkColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            children: [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(text: 'Terms & Conditions',
                                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500)),
                              TextSpan(text: ' and '),
                              TextSpan(text: 'Privacy Policy',
                                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Consumer<UserProvider>(
                    builder: (_, userProv, __) => Column(
                      children: [
                        CustomButton(
                          label: 'CREATE ACCOUNT',
                          onTap: _register,
                          isLoading: userProv.loading,
                          width: double.infinity,
                        ),
                        if (userProv.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(userProv.error!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 12))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text('Sign In',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator,
      );
}
