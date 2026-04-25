// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/search_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/help_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/change_password_screen.dart';

// ── Route name constants ───────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._(); // prevent instantiation

  // Core
  static const String splash         = '/';
  static const String login          = '/login';
  static const String register       = '/register';
  static const String main           = '/main';

  // Shopping flow
  static const String home           = '/home';       
  static const String products       = '/products';   
  static const String productList    = '/product-list';
  static const String productDetail  = '/product-detail';
  static const String cart           = '/cart';       
  static const String checkout       = '/checkout';

  // User area
  static const String profile        = '/profile';    
  static const String wishlist       = '/wishlist';  
  static const String settings       = '/settings';
  static const String search         = '/search';
  static const String editProfile    = '/edit-profile';
  static const String orders         = '/orders';
  static const String reviews        = '/reviews';   
  static const String help           = '/help';
  static const String changePassword  = '/change-password';
  static const String paymentMethods = '/payment-methods';

  // ── Plain WidgetBuilder map ─────────────────────────────────────────────────
  static Map<String, WidgetBuilder> get routes => {
    splash:         (_) => const SplashScreen(),
    login:          (_) => const LoginScreen(),
    register:       (_) => const RegisterScreen(),
    main:           (_) => const MainScreen(),
    home:           (_) => const MainScreen(),
    cart:           (_) => const MainScreen(),
    profile:        (_) => const MainScreen(),
    wishlist:       (_) => const MainScreen(),
    checkout:       (_) => const CheckoutScreen(),
    settings:       (_) => const SettingsScreen(),
    search:         (_) => const SearchScreen(),
    editProfile:    (_) => const EditProfileScreen(),
    orders:         (_) => const OrdersScreen(),
    help:           (_) => const HelpScreen(),
    changePassword:  (_) => const ChangePasswordScreen(),
    paymentMethods:  (_) => const PaymentMethodsScreen(),
    reviews:        (_) => const OrdersScreen(),
  };
}
