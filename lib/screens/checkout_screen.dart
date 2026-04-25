// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/payment_method_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Step 0 = Delivery, 1 = Payment, 2 = Review
  int _step = 0;

  // ── Delivery form ────────────────────────────────────────────────────────────
  final _deliveryKey  = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _cityCtrl     = TextEditingController();
  final _zipCtrl      = TextEditingController();
  String _delivery    = 'standard'; // 'standard' | 'express'

  // ── Payment form ─────────────────────────────────────────────────────────────
  final _paymentKey   = GlobalKey<FormState>();
  int _paymentMethod  = 0;           // 0=Card, 1=PayPal, 2=Apple Pay
  final _cardCtrl     = TextEditingController();
  final _expiryCtrl   = TextEditingController();
  final _cvvCtrl      = TextEditingController();

  bool _loading = false;
  // Whether the user is using a saved card from PaymentMethodProvider
  bool _usingSavedCard = false;
  String? _savedCardId; // id of the card being used

  // Delivery cost map
  double get _shippingCost => _delivery == 'express' ? 19.99 : 9.99;

  @override
  void initState() {
    super.initState();
    // Pre-fill from user profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pre-fill delivery from user profile
      final user = context.read<UserProvider>().user;
      if (user != null) {
        _nameCtrl.text    = user.fullName;
        _emailCtrl.text   = user.email;
        _phoneCtrl.text   = user.phone;
        _addressCtrl.text = user.address;
        _cityCtrl.text    = user.city;
        _zipCtrl.text     = user.zip;
      }
      // Pre-select default saved card if one exists
      final defaultCard = context.read<PaymentMethodProvider>().defaultMethod;
      if (defaultCard != null) {
        setState(() {
          _usingSavedCard = true;
          _savedCardId    = defaultCard.id;
          _paymentMethod  = 0; // Card tab
        });
      }
    });
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl,
      _addressCtrl, _cityCtrl, _zipCtrl,
      _cardCtrl, _expiryCtrl, _cvvCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────────
  void _next() {
    if (_step == 0) {
      if (!_deliveryKey.currentState!.validate()) return;
      setState(() => _step = 1);
    } else if (_step == 1) {
      // Skip manual card form validation when user has a saved card selected
      if (_paymentMethod == 0 && !_usingSavedCard) {
        if (!_paymentKey.currentState!.validate()) return;
      }
      setState(() => _step = 2);
    } else {
      _placeOrder();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _placeOrder() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final cart     = context.read<CartProvider>();
    final userProv = context.read<UserProvider>();

    // Store order in UserProvider
    userProv.placeOrder(
      items:           cart.items.toList(),
      total:           cart.subtotal + _shippingCost,
      deliveryAddress: '${_addressCtrl.text}, ${_cityCtrl.text} ${_zipCtrl.text}',
    );

    // Update user profile address if they typed one
    if (_addressCtrl.text.isNotEmpty) {
      userProv.updateProfile(
        fullName: _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        phone:    _phoneCtrl.text.trim(),
        address:  _addressCtrl.text.trim(),
        city:     _cityCtrl.text.trim(),
        zip:      _zipCtrl.text.trim(),
      );
    }

    cart.clearCart();
    setState(() => _loading = false);
    _showSuccess();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Order Placed!',
                style: TextStyle(color: AppColors.white, fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Your order has been successfully placed.\nYou\'ll receive a confirmation shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'BACK TO HOME',
              width: double.infinity,
              onTap: () {
                Navigator.of(context).pop();              // close dialog
                Navigator.of(context).pop();              // close checkout
              },
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'VIEW MY ORDERS',
              style: ButtonStyle2.outlined,
              width: double.infinity,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.orders);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartTotal = cart.subtotal + _shippingCost;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _back,
        ),
      ),
      body: Column(
        children: [
          // ── Step indicator ────────────────────────────────────────────────
          _StepIndicator(current: _step),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.08, 0), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
                child: _step == 0
                    ? _DeliveryStep(
                        key: const ValueKey('delivery'),
                        formKey:     _deliveryKey,
                        nameCtrl:    _nameCtrl,
                        emailCtrl:   _emailCtrl,
                        phoneCtrl:   _phoneCtrl,
                        addressCtrl: _addressCtrl,
                        cityCtrl:    _cityCtrl,
                        zipCtrl:     _zipCtrl,
                        delivery:    _delivery,
                        onDeliveryChanged: (v) => setState(() => _delivery = v),
                      )
                    : _step == 1
                        ? _PaymentStep(
                            key: const ValueKey('payment'),
                            formKey:          _paymentKey,
                            paymentMethod:    _paymentMethod,
                            onMethodChanged:  (v) => setState(() {
                              _paymentMethod = v;
                              // Switching away from Card tab deselects the saved card
                              if (v != 0) _usingSavedCard = false;
                            }),
                            cardCtrl:         _cardCtrl,
                            expiryCtrl:       _expiryCtrl,
                            cvvCtrl:          _cvvCtrl,
                            usingSavedCard:   _usingSavedCard,
                            savedCardId:      _savedCardId,
                            onUseSavedCard:   (useSaved, id) => setState(() {
                              _usingSavedCard = useSaved;
                              _savedCardId    = id;
                            }),
                          )
                        : _ReviewStep(
                            key: const ValueKey('review'),
                            cart:      cart,
                            name:      _nameCtrl.text,
                            address:   '${_addressCtrl.text}, ${_cityCtrl.text} ${_zipCtrl.text}',
                            delivery:  _delivery,
                            shipping:  _shippingCost,
                            total:     cartTotal,
                          ),
              ),
            ),
          ),

          // ── Bottom buttons ────────────────────────────────────────────────
          _BottomBar(
            step:      _step,
            isLoading: _loading,
            onBack:    _back,
            onNext:    _next,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Step Indicator
// ══════════════════════════════════════════════════════════════════════════════
class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    const steps = ['Delivery', 'Payment', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (i) {
          final isActive   = i == current;
          final isComplete = i < current;
          return Row(
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.success
                          : isActive
                              ? AppColors.accent
                              : AppColors.divider,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isComplete
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text('${i + 1}',
                              style: TextStyle(
                                color: isActive ? AppColors.primary : AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              )),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(steps[i],
                      style: TextStyle(
                        color: isActive ? AppColors.accent : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      )),
                ],
              ),
              if (i < steps.length - 1)
                Container(
                  width: 50, height: 1,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: i < current ? AppColors.success : AppColors.divider,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Step 1 — Delivery
// ══════════════════════════════════════════════════════════════════════════════
class _DeliveryStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl,
      addressCtrl, cityCtrl, zipCtrl;
  final String delivery;
  final ValueChanged<String> onDeliveryChanged;

  const _DeliveryStep({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.zipCtrl,
    required this.delivery,
    required this.onDeliveryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Contact Information'),
          const SizedBox(height: 16),
          _buildField(nameCtrl,  'Full Name',      Icons.person_outline,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          _buildField(emailCtrl, 'Email Address',   Icons.email_outlined,
              type: TextInputType.emailAddress,
              validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null),
          const SizedBox(height: 12),
          _buildField(phoneCtrl, 'Phone Number',    Icons.phone_outlined,
              type: TextInputType.phone,
              validator: (v) => v == null || v.trim().length < 6 ? 'Enter valid phone' : null),

          const SizedBox(height: 24),
          _sectionTitle('Delivery Address'),
          const SizedBox(height: 16),
          _buildField(addressCtrl, 'Street Address', Icons.location_on_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildField(cityCtrl, 'City', Icons.location_city_outlined,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(zipCtrl, 'ZIP Code', Icons.pin_drop_outlined,
                    type: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v == null || v.length < 4 ? 'Invalid ZIP' : null),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _sectionTitle('Delivery Option'),
          const SizedBox(height: 12),
          _DeliveryOption(
            title:      'Standard Delivery',
            subtitle:   '5–7 business days',
            price:      '\$9.99',
            value:      'standard',
            groupValue: delivery,
            onChanged:  onDeliveryChanged,
          ),
          const SizedBox(height: 8),
          _DeliveryOption(
            title:      'Express Delivery',
            subtitle:   '2–3 business days',
            price:      '\$19.99',
            value:      'express',
            groupValue: delivery,
            onChanged:  onDeliveryChanged,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  final String title, subtitle, price, value, groupValue;
  final ValueChanged<String> onChanged;

  const _DeliveryOption({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withAlpha(20)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: selected ? AppColors.white : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      )),
                  Text(subtitle,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Text(price,
                style: TextStyle(
                  color: selected ? AppColors.accent : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Step 2 — Payment
// ══════════════════════════════════════════════════════════════════════════════
class _PaymentStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final int paymentMethod;
  final ValueChanged<int> onMethodChanged;
  final TextEditingController cardCtrl, expiryCtrl, cvvCtrl;
  // Saved-card integration
  final bool usingSavedCard;
  final String? savedCardId;
  final void Function(bool useSaved, String? id) onUseSavedCard;

  const _PaymentStep({
    super.key,
    required this.formKey,
    required this.paymentMethod,
    required this.onMethodChanged,
    required this.cardCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
    required this.usingSavedCard,
    required this.savedCardId,
    required this.onUseSavedCard,
  });

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentMethodProvider>();
    final hasSavedCards   = !paymentProvider.isEmpty;
    final allCards        = paymentProvider.methods;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Payment Method'),
          const SizedBox(height: 16),

          // ── Method tabs ───────────────────────────────────────────────────
          Row(
            children: [
              _MethodTab(label: 'Card',   icon: Icons.credit_card_rounded,    index: 0, selected: paymentMethod, onTap: onMethodChanged),
              const SizedBox(width: 8),
              _MethodTab(label: 'PayPal', icon: Icons.account_balance_wallet, index: 1, selected: paymentMethod, onTap: onMethodChanged),
              const SizedBox(width: 8),
              _MethodTab(label: 'Apple',  icon: Icons.apple_rounded,          index: 2, selected: paymentMethod, onTap: onMethodChanged),
            ],
          ),
          const SizedBox(height: 20),

          if (paymentMethod == 0) ...[
            // ── Card tab: show saved cards first if any exist ─────────────

            if (hasSavedCards) ...[
              // Saved card selector
              _sectionTitle('Saved Cards'),
              const SizedBox(height: 12),

              // List all saved cards as selectable tiles
              ...allCards.map((card) {
                final isSelected = usingSavedCard && savedCardId == card.id;
                return GestureDetector(
                  onTap: () => onUseSavedCard(true, card.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withAlpha(20)
                          : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.divider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.accent : AppColors.divider,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10, height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // Card icon
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.credit_card_rounded,
                              color: AppColors.accent, size: 18),
                        ),
                        const SizedBox(width: 12),
                        // Card info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${card.networkLabel}  ${card.displayNumber}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (card.isDefault) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withAlpha(38),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('DEFAULT',
                                          style: TextStyle(
                                              color: AppColors.success,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${card.cardholderName}  •  Exp ${card.displayExpiry}',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Option to use a different (new) card instead
              GestureDetector(
                onTap: () => onUseSavedCard(false, null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: !usingSavedCard ? AppColors.accent.withAlpha(20) : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: !usingSavedCard ? AppColors.accent : AppColors.divider,
                      width: !usingSavedCard ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: !usingSavedCard ? AppColors.accent : AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: !usingSavedCard
                            ? Center(
                                child: Container(
                                  width: 10, height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_card_rounded,
                            color: AppColors.accent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text('Use a different card',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),

              // Manual card entry fields — shown only when "Use different card" is selected
              if (!usingSavedCard) ...[
                const SizedBox(height: 20),
                _sectionTitle('Enter Card Details'),
                const SizedBox(height: 12),
                _manualCardFields(context),
              ],
            ] else ...[
              // No saved cards at all — show manual entry directly
              _manualCardFields(context),
            ],
          ] else ...[
            // PayPal / Apple Pay placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  paymentMethod == 1
                      ? 'You will be redirected to PayPal\nto complete your payment securely.'
                      : 'Use Face ID or Touch ID\nto pay with Apple Pay.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 14, height: 1.6),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Extracted manual card entry form
  Widget _manualCardFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: cardCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.white),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          maxLength: 19,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card_rounded),
            counterText: '',
          ),
          validator: (v) {
            final raw = v?.replaceAll(' ', '') ?? '';
            return raw.length < 16 ? 'Enter a valid 16-digit card number' : null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: expiryCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.white),
                inputFormatters: [_ExpiryFormatter()],
                maxLength: 5,
                decoration: const InputDecoration(
                  labelText: 'MM / YY',
                  hintText: '12/26',
                  prefixIcon: Icon(Icons.date_range_outlined),
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.length < 5) return 'Invalid expiry';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cvvCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                style: const TextStyle(color: AppColors.white),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '•••',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v == null || v.length < 3 ? 'Invalid CVV' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.success.withAlpha(77)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.success, size: 16),
              SizedBox(width: 8),
              Text('Your payment info is encrypted & secure',
                  style: TextStyle(color: AppColors.success, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Step 3 — Review
// ══════════════════════════════════════════════════════════════════════════════
class _ReviewStep extends StatelessWidget {
  final CartProvider cart;
  final String name, address, delivery;
  final double shipping, total;

  const _ReviewStep({
    super.key,
    required this.cart,
    required this.name,
    required this.address,
    required this.delivery,
    required this.shipping,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Delivery To'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isNotEmpty ? name : 'Customer',
                        style: const TextStyle(
                            color: AppColors.white, fontWeight: FontWeight.w600)),
                    Text(address.isNotEmpty ? address : 'No address provided',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(38),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        delivery == 'express' ? 'Express (2–3 days)' : 'Standard (5–7 days)',
                        style: const TextStyle(
                            color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _sectionTitle('Order Items'),
        const SizedBox(height: 12),
        ...cart.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(item.product.imageUrl,
                        width: 56, height: 56, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 56, height: 56, color: AppColors.surface)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name,
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('${item.selectedSize} • ${item.selectedColor} × ${item.quantity}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            )),
        const SizedBox(height: 16),
        _summaryRow('Subtotal',  '\$${cart.subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 6),
        _summaryRow('Shipping',  '\$${shipping.toStringAsFixed(2)}'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: AppColors.divider),
        ),
        _summaryRow('Total',     '\$${total.toStringAsFixed(2)}', bold: true),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: bold ? AppColors.white : AppColors.textMuted,
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              )),
          Text(value,
              style: TextStyle(
                color: bold ? AppColors.accent : AppColors.white,
                fontSize: bold ? 18 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              )),
        ],
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Bottom Bar
// ══════════════════════════════════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  final int step;
  final bool isLoading;
  final VoidCallback onBack, onNext;

  const _BottomBar({
    required this.step,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Back',
                      style: TextStyle(
                          color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: CustomButton(
              label: step == 2 ? 'PLACE ORDER' : 'CONTINUE',
              onTap:     onNext,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Input Formatters
// ══════════════════════════════════════════════════════════════════════════════
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    var text = newVal.text.replaceAll('/', '').replaceAll(RegExp(r'\D'), '');
    if (text.length > 4) text = text.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    final str = buffer.toString();
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}


// ══════════════════════════════════════════════════════════════════════════════
// _MethodTab — payment method selector tab (Card / PayPal / Apple Pay)
// ══════════════════════════════════════════════════════════════════════════════
class _MethodTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;

  const _MethodTab({
    required this.label,
    required this.icon,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSel = index == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? AppColors.accent.withAlpha(31) : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? AppColors.accent : AppColors.divider,
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSel ? AppColors.accent : AppColors.textMuted,
                  size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSel ? AppColors.accent : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared helpers
// ══════════════════════════════════════════════════════════════════════════════
Widget _sectionTitle(String text) => Text(
      text,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );

Widget _buildField(
  TextEditingController ctrl,
  String label,
  IconData icon, {
  TextInputType type = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
}) =>
    TextFormField(
      controller: ctrl,
      keyboardType: type,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );