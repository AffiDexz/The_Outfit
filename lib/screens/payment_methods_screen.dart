// lib/screens/payment_methods_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/payment_method_model.dart';
import '../providers/payment_method_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentMethodProvider>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Payment Methods'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isEmpty
          ? _EmptyState(onAdd: () => _openSheet(context, null))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      // ── Info banner ─────────────────────────────────────────
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.25)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_rounded,
                                color: AppColors.accent, size: 16),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your payment details are stored locally '
                                'and never shared.',
                                style: TextStyle(
                                    color: AppColors.accent, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Card list ────────────────────────────────────────────
                      ...provider.methods.map((m) => _CardTile(
                            method: m,
                            onEdit: () => _openSheet(context, m),
                            onDelete: () => _confirmDelete(context, m),
                            onSetDefault: () =>
                                context
                                    .read<PaymentMethodProvider>()
                                    .setDefault(m.id),
                          )),
                    ],
                  ),
                ),

                // ── Add button ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: CustomButton(
                    label: 'ADD NEW CARD',
                    icon: Icons.add_rounded,
                    width: double.infinity,
                    onTap: () => _openSheet(context, null),
                  ),
                ),
              ],
            ),
      // FAB only shows when list is non-empty (Add button at bottom handles it)
    );
  }

  // ── Bottom sheet: Add / Edit ───────────────────────────────────────────────
  void _openSheet(BuildContext context, PaymentMethodModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PaymentMethodProvider>(),
        child: _CardFormSheet(existing: existing),
      ),
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, PaymentMethodModel m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Card',
            style: TextStyle(color: AppColors.white)),
        content: Text(
          'Remove ${m.displayNumber} from your saved cards?',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              context.read<PaymentMethodProvider>().deleteMethod(m.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Card removed',
                      style: TextStyle(color: AppColors.white)),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Remove',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Card Tile Widget
// ═══════════════════════════════════════════════════════════════════════════════
class _CardTile extends StatelessWidget {
  final PaymentMethodModel method;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _CardTile({
    required this.method,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          // ── Visual card ───────────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 174,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientColors(),
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -20, right: -20,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30, right: 40,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chip
                      Container(
                        width: 40, height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const Spacer(),
                      // Card number
                      Text(
                        method.displayNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CARDHOLDER',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 9,
                                      letterSpacing: 1)),
                              const SizedBox(height: 2),
                              Text(
                                method.cardholderName.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('EXPIRES',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 9,
                                      letterSpacing: 1)),
                              const SizedBox(height: 2),
                              Text(
                                method.displayExpiry,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Network label top-right
                Positioned(
                  top: 16, right: 18,
                  child: Text(
                    method.networkLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                // Default badge
                if (method.isDefault)
                  Positioned(
                    top: 14, left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text('DEFAULT',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ),
                  ),
              ],
            ),
          ),

          // ── Action bar ────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppColors.cardBg,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                // Set default
                if (!method.isDefault)
                  _action(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Set Default',
                    color: AppColors.accent,
                    onTap: onSetDefault,
                  ),
                if (!method.isDefault)
                  Container(
                      width: 1, height: 40, color: AppColors.divider),
                // Edit
                _action(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: AppColors.white,
                  onTap: onEdit,
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                // Delete
                _action(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove',
                  color: AppColors.error,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 15),
                const SizedBox(width: 5),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

  List<Color> _gradientColors() {
    switch (method.network) {
      case CardNetwork.visa:
        return [const Color(0xFF1A2A4A), const Color(0xFF0D1B2E)];
      case CardNetwork.mastercard:
        return [const Color(0xFF2A1A0E), const Color(0xFF3D2008)];
      case CardNetwork.amex:
        return [const Color(0xFF1A3A2A), const Color(0xFF0D2018)];
      case CardNetwork.other:
        return [const Color(0xFF2A1A2E), const Color(0xFF1A0D2A)];
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Add / Edit Bottom Sheet Form
// ═══════════════════════════════════════════════════════════════════════════════
class _CardFormSheet extends StatefulWidget {
  final PaymentMethodModel? existing;
  const _CardFormSheet({required this.existing});

  @override
  State<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<_CardFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _numberCtrl;
  late TextEditingController _expiryCtrl;
  CardNetwork _network = CardNetwork.visa;
  bool _makeDefault = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl   = TextEditingController(text: e?.cardholderName ?? '');
    _numberCtrl = TextEditingController(text: e?.maskedNumber ?? '');
    _expiryCtrl = TextEditingController(
        text: e != null ? '${e.expiryMonth}/${e.expiryYear}' : '');
    _network      = e?.network ?? CardNetwork.visa;
    _makeDefault  = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // Parse expiry "MM/YY"
    final parts = _expiryCtrl.text.split('/');
    final month = parts[0].trim();
    final year  = parts.length > 1 ? parts[1].trim() : '';

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final provider = context.read<PaymentMethodProvider>();
    if (_isEditing) {
      provider.editMethod(
        id:             widget.existing!.id,
        cardholderName: _nameCtrl.text,
        maskedNumber:   _numberCtrl.text.replaceAll(' ', '').length >= 4
            ? _numberCtrl.text.replaceAll(' ', '').substring(
                _numberCtrl.text.replaceAll(' ', '').length - 4)
            : _numberCtrl.text,
        expiryMonth:    month,
        expiryYear:     year,
        network:        _network,
        makeDefault:    _makeDefault,
      );
    } else {
      final raw = _numberCtrl.text.replaceAll(' ', '');
      provider.addMethod(
        cardholderName: _nameCtrl.text,
        maskedNumber:   raw.length >= 4 ? raw.substring(raw.length - 4) : raw,
        expiryMonth:    month,
        expiryYear:     year,
        network:        _network,
        makeDefault:    _makeDefault,
      );
    }

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.accent),
          const SizedBox(width: 10),
          Text(_isEditing ? 'Card updated!' : 'Card added!',
              style: const TextStyle(color: AppColors.white)),
        ]),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  _isEditing ? 'Edit Card' : 'Add New Card',
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),

                // ── Network selector ─────────────────────────────────────────
                _sectionLabel('Card Network'),
                const SizedBox(height: 10),
                Row(
                  children: CardNetwork.values.map((n) {
                    final selected = _network == n;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _network = n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accent.withValues(alpha: 0.12)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.divider,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            _networkLabel(n),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ── Cardholder name ──────────────────────────────────────────
                _sectionLabel('Cardholder Name'),
                const SizedBox(height: 8),
                _field(
                  ctrl: _nameCtrl,
                  hint: 'Cardholder Name',
                  icon: Icons.person_outline,
                  type: TextInputType.name,
                  validator: (v) => v == null || v.trim().length < 2
                      ? 'Enter cardholder name'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Card number ──────────────────────────────────────────────
                _sectionLabel(
                    _isEditing ? 'Last 4 Digits' : 'Card Number'),
                const SizedBox(height: 8),
                _field(
                  ctrl: _numberCtrl,
                  hint: _isEditing ? '4242' : '1234 5678 9012 3456',
                  icon: Icons.credit_card_rounded,
                  type: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_isEditing ? 4 : 16),
                    if (!_isEditing) _CardNumberFormatter(),
                  ],
                  validator: (v) {
                    final raw = v?.replaceAll(' ', '') ?? '';
                    if (_isEditing) {
                      return raw.length != 4 ? 'Enter last 4 digits' : null;
                    }
                    return raw.length < 13
                        ? 'Enter a valid card number'
                        : null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Expiry ───────────────────────────────────────────────────
                _sectionLabel('Expiry Date'),
                const SizedBox(height: 8),
                _field(
                  ctrl: _expiryCtrl,
                  hint: 'MM/YY',
                  icon: Icons.date_range_outlined,
                  type: TextInputType.number,
                  inputFormatters: [_ExpiryFormatter()],
                  validator: (v) {
                    if (v == null || v.length < 5) {
                      return 'Enter expiry as MM/YY';
                    }
                    final parts = v.split('/');
                    final month = int.tryParse(parts[0]);
                    if (month == null || month < 1 || month > 12) {
                      return 'Invalid month';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Set as default toggle ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Set as default payment method',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                      Switch(
                        value: _makeDefault,
                        onChanged: (v) => setState(() => _makeDefault = v),
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
                ),
                const SizedBox(height: 28),

                // ── Save button ──────────────────────────────────────────────
                CustomButton(
                  label: _isEditing ? 'UPDATE CARD' : 'ADD CARD',
                  icon: _isEditing ? Icons.edit_outlined : Icons.add_rounded,
                  onTap: _save,
                  isLoading: _saving,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: AppColors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: validator,
      );

  String _networkLabel(CardNetwork n) {
    switch (n) {
      case CardNetwork.visa:       return 'Visa';
      case CardNetwork.mastercard: return 'MC';
      case CardNetwork.amex:       return 'Amex';
      case CardNetwork.other:      return 'Other';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.credit_card_rounded,
                  color: AppColors.divider, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Payment Methods',
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a credit or debit card\nto speed up checkout.',
              style:
                  TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('ADD A CARD',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Input formatters
// ═══════════════════════════════════════════════════════════════════════════════
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
        selection: TextSelection.collapsed(offset: str.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    var text =
        newVal.text.replaceAll('/', '').replaceAll(RegExp(r'\D'), '');
    if (text.length > 4) text = text.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    final str = buffer.toString();
    return newVal.copyWith(
        text: str,
        selection: TextSelection.collapsed(offset: str.length));
  }
}