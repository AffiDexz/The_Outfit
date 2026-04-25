# The Outfit — Flutter Fashion App
### CIT211 Mobile Software Development · Individual Coursework · Phase 1

---

## Overview

**The Outfit** is a premium fashion e-commerce mobile application built with Flutter. This is **Phase 1** — a complete UI/UX + frontend implementation using local state management and static product data. No Firebase integration at this stage.

**Design language:** Matte Black `#0F0F0F` · Gold `#C9A44C` · White `#FFFFFF` · Poppins typography

---

## Quick Start

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | >= 3.0.0 |
| Dart SDK | >= 3.0.0 |
| Android Studio or VS Code | Latest |
| Android Emulator or Device | API 21+ |

### 1. Verify Flutter

```bash
flutter doctor
```

### 2. Install dependencies

```bash
cd the_outfit
flutter pub get
```

### 3. Add local image assets

Place your product images inside `assets/images/`. The following filenames are expected by `product_data.dart`:

```
assets/images/
  suit.jpg         cargo.jpg       turtleneck.jpg  Shirts.jpg
  Silk.jpg         Puff.jpg        Cardigan.jpg    Linen.jpg
  Necklace.jpg     stuff.jpg       Wallet.jpg      Belt.jpg
  Boots.jpg        Sneakers.jpg    Sneakers2.jpg   Shoes.jpg
  Overcoat.jpg     Jacket.jpg      Zipper.jpg      Children.jpg
```

Make sure `pubspec.yaml` declares the folder:

```yaml
flutter:
  assets:
    - assets/images/
```

### 4. Run

```bash
flutter run
```

### 5. Build APK (release)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Project Structure

```
lib/
├── main.dart                        # Entry point, MultiProvider, onGenerateRoute
│
├── models/
│   ├── product_model.dart           # Product entity (const constructor)
│   ├── cart_item_model.dart         # CartItem (product + qty + size + color)
│   ├── user_model.dart              # UserModel with initials getter
│   ├── order_model.dart             # OrderModel with status enum
│   └── payment_method_model.dart    # PaymentMethodModel (last-4 only)
│
├── providers/
│   ├── user_provider.dart           # Auth, profile update, order history
│   ├── cart_provider.dart           # CRUD cart, totals
│   ├── wishlist_provider.dart       # Wishlist toggle
│   ├── settings_provider.dart       # Dark mode, notifications, language, currency
│   └── payment_method_provider.dart # CRUD saved payment cards
│
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_screen.dart             # Bottom nav shell (IndexedStack x 4 tabs)
│   ├── home_screen.dart
│   ├── product_listing_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   ├── wishlist_screen.dart
│   ├── checkout_screen.dart         # 3-step: Delivery -> Payment -> Review
│   ├── orders_screen.dart
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   ├── payment_methods_screen.dart  # CRUD saved cards
│   ├── settings_screen.dart
│   ├── search_screen.dart
│   ├── help_screen.dart
│   └── change_password_screen.dart
│
├── widgets/
│   ├── product_card.dart
│   ├── category_card.dart
│   ├── wishlist_item.dart
│   └── custom_button.dart
│
├── routes/
│   └── app_routes.dart              # All named route constants
│
├── services/
│   └── product_data.dart            # 20 static products
│
└── utils/
    ├── app_constants.dart           # AppColors, AppTheme, re-exports AppRoutes
    └── page_routes.dart             # Custom page transition classes
```

---

## Screens

| # | Screen | Description |
|---|--------|-------------|
| 1 | Splash | Staggered logo animation, auto-navigates after 3 s |
| 2 | Login | Form validation, slide-up animation |
| 3 | Register | Full validation, terms checkbox |
| 4 | Home | Hero banner, category pills, product grid |
| 5 | Product Listing | Sort, category filter, item count |
| 6 | Product Detail | Hero image, size/color selectors, Add to Cart animation |
| 7 | Cart | Swipe-to-delete, qty +/-, order summary |
| 8 | Wishlist | Add to Cart per item, Add All to Cart |
| 9 | Checkout | 3-step stepper, saved card auto-fill, delivery options |
| 10 | Orders | Full order history with status badges |
| 11 | Profile | Dynamic stats, full menu navigation |
| 12 | Edit Profile | Pre-filled form, saves via UserProvider |
| 13 | Payment Methods | Visual card tiles, CRUD, set-default |
| 14 | Settings | Dark mode, notifications, language and currency dropdowns |
| 15 | Search | Real-time local filter, trending, recent searches |
| 16 | Help | FAQ accordion, contact buttons |
| 17 | Change Password | Validated form |

---

## Navigation

All routes are defined in `lib/routes/app_routes.dart` and registered in `main.dart` via `onGenerateRoute`.

```dart
AppRoutes.splash          = '/'
AppRoutes.login           = '/login'
AppRoutes.main            = '/main'
AppRoutes.cart            = '/cart'
AppRoutes.wishlist        = '/wishlist'
AppRoutes.productDetail   = '/product-detail'
AppRoutes.checkout        = '/checkout'
AppRoutes.paymentMethods  = '/payment-methods'
AppRoutes.orders          = '/orders'
AppRoutes.editProfile     = '/edit-profile'
AppRoutes.settings        = '/settings'
AppRoutes.search          = '/search'
AppRoutes.help            = '/help'
AppRoutes.changePassword  = '/change-password'
```

Transitions used:
- `FadeScaleRoute` — default push (fade + 5% scale)
- `SlideRightRoute` — standard drill-down screens
- `SlideUpRoute` — modal screens (Cart, Checkout)

---

## State Management

Five `ChangeNotifier` providers registered at the app root via `MultiProvider`:

| Provider | Responsibility |
|---|---|
| `UserProvider` | Login, logout, profile update, order history |
| `CartProvider` | Add/remove/qty, subtotal, shipping, total |
| `WishlistProvider` | Toggle, count |
| `SettingsProvider` | Dark mode, notifications, language, currency |
| `PaymentMethodProvider` | CRUD saved cards, set-default |

---

## Animations

| Animation | Where | Implementation |
|---|---|---|
| Hero | Product image: Listing to Detail | `Hero` widget with matching `heroTag` |
| Splash stagger | Logo scale + text fade | `AnimationController` + `Interval` |
| Page transitions | Every screen push | `PageRouteBuilder` subclasses |
| Add to Cart | Compress, overshoot, settle + glow + particles | `TweenSequence` + `HapticFeedback` |
| Category pills | Color and size change | `AnimatedContainer` |
| Bottom nav | Icon swap and label | `AnimatedSwitcher` |
| Button tap | Scale micro-interaction | `ScaleTransition` in `CustomButton` |

---

## Dependencies

```yaml
provider: ^6.1.1
google_fonts: ^6.1.0
cached_network_image: ^3.3.1
smooth_page_indicator: ^1.1.0
flutter_rating_bar: ^4.0.1
badges: ^3.1.2
shared_preferences: ^2.2.2
```

---

## Design System

| Token | Value | Usage |
|---|---|---|
| `AppColors.primary` | `#0F0F0F` | Background, AppBar |
| `AppColors.accent` | `#C9A44C` | Buttons, highlights, prices |
| `AppColors.white` | `#FFFFFF` | Primary text |
| `AppColors.surface` | `#1A1A1A` | Cards, bottom nav |
| `AppColors.cardBg` | `#222222` | Product cards |
| `AppColors.divider` | `#2E2E2E` | Borders, separators |
| `AppColors.textMuted` | `#888888` | Secondary text |
| `AppColors.error` | `#CF6679` | Errors, delete actions |
| `AppColors.success` | `#4CAF50` | Order confirmed, secure badges |

---
*Phase 1 Submission — CIT211 Mobile Software Development*  
*Bachelor of Science in Applied Information Technology*
