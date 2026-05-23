// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

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
    // Clear any leftover error from previous session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final userProv = context.read<UserProvider>();
    final success  = await userProv.login(
      email:    _emailCtrl.text,
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      // Error is shown below the button via Consumer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accent, width: 1.5),
                            ),
                            child: const Icon(Icons.diamond_outlined, color: AppColors.accent, size: 28),
                          ),
                          const SizedBox(height: 12),
                          const Text('THE OUTFIT',
                              style: TextStyle(color: AppColors.white, fontSize: 20,
                                  fontWeight: FontWeight.w800, letterSpacing: 6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 52),
                    const Text('Welcome Back',
                        style: TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('Sign in to continue',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    const SizedBox(height: 36),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textMuted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('Forgot Password?',
                          style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 30),

                    // Sign in button
                    Consumer<UserProvider>(
                      builder: (_, userProv, __) => Column(
                        children: [
                          CustomButton(
                            label: 'SIGN IN',
                            onTap: _login,
                            isLoading: userProv.loading,
                            width: double.infinity,
                          ),
                          // Firebase error message
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
                                  Expanded(
                                    child: Text(userProv.error!,
                                        style: const TextStyle(color: AppColors.error, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Row(children: [
                      Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: AppColors.divider)),
                    ]),
                    const SizedBox(height: 28),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ",
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                            child: const Text('Register',
                                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
