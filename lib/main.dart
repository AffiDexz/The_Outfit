// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_provider.dart';
import 'providers/payment_method_provider.dart';
import 'utils/app_constants.dart';
import 'utils/page_routes.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/product_listing_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/search_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/help_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/payment_methods_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:                    Colors.transparent,
    statusBarIconBrightness:           Brightness.light,
    systemNavigationBarColor:          AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const TheOutfitApp());
}

class TheOutfitApp extends StatelessWidget {
  const TheOutfitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PaymentMethodProvider()),
      ],
      child: MaterialApp(
        title: 'The Outfit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return FadeScaleRoute(
                  page: const SplashScreen(), routeSettings: settings);

            case AppRoutes.login:
              return FadeScaleRoute(
                  page: const LoginScreen(), routeSettings: settings);

            case AppRoutes.register:
              return SlideRightRoute(
                  page: const RegisterScreen(), routeSettings: settings);

            // Main shell — Home and Profile tabs open via the bottom nav shell.
            case AppRoutes.main:
            case AppRoutes.home:
            case AppRoutes.profile:
              return FadeScaleRoute(
                  page: const MainScreen(), routeSettings: settings);

            // Cart opens as a stand-alone screen pushed on top of MainScreen.
            case AppRoutes.cart:
              return SlideUpRoute(page: const CartScreen());

            // Wishlist opens as a stand-alone screen (back button works).
            case AppRoutes.wishlist:
              return SlideRightRoute(
                  page: const WishlistScreen(), routeSettings: settings);

            case AppRoutes.productList:
            case AppRoutes.products:
              return SlideRightRoute(
                  page: const ProductListingScreen(),
                  routeSettings: settings);

            case AppRoutes.productDetail:
              return FadeScaleRoute(
                  page: const ProductDetailScreen(),
                  routeSettings: settings);

            case AppRoutes.checkout:
              return SlideUpRoute(page: const CheckoutScreen());

            case AppRoutes.settings:
              return SlideRightRoute(
                  page: const SettingsScreen(), routeSettings: settings);

            case AppRoutes.search:
              return FadeScaleRoute(
                  page: const SearchScreen(), routeSettings: settings);

            case AppRoutes.orders:
            case AppRoutes.reviews:
              return SlideRightRoute(
                  page: const OrdersScreen(), routeSettings: settings);

            case AppRoutes.editProfile:
              return SlideRightRoute(
                  page: const EditProfileScreen(),
                  routeSettings: settings);

            case AppRoutes.help:
              return SlideRightRoute(
                  page: const HelpScreen(), routeSettings: settings);

            case AppRoutes.paymentMethods:
              return SlideRightRoute(
                  page: const PaymentMethodsScreen(),
                  routeSettings: settings);

            case AppRoutes.changePassword:
              return SlideRightRoute(
                  page: const ChangePasswordScreen(),
                  routeSettings: settings);

            default:
              return FadeScaleRoute(
                  page: const LoginScreen(), routeSettings: settings);
          }
        },
      ),
    );
  }
}
