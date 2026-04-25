// lib/providers/payment_method_provider.dart
import 'package:flutter/material.dart';
import '../models/payment_method_model.dart';

class PaymentMethodProvider extends ChangeNotifier {
  final List<PaymentMethodModel> _methods = [];

  List<PaymentMethodModel> get methods => List.unmodifiable(_methods);

  bool get isEmpty => _methods.isEmpty;

  PaymentMethodModel? get defaultMethod {
    try {
      return _methods.firstWhere((m) => m.isDefault);
    } catch (_) {
      return _methods.isNotEmpty ? _methods.first : null;
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────────
  void addMethod({
    required String cardholderName,
    required String maskedNumber,
    required String expiryMonth,
    required String expiryYear,
    required CardNetwork network,
    bool makeDefault = false,
  }) {
    final id = 'pm_${DateTime.now().millisecondsSinceEpoch}';

    // If this is the first card or explicitly set as default,
    // clear default flag on existing cards first.
    if (makeDefault || _methods.isEmpty) {
      for (int i = 0; i < _methods.length; i++) {
        if (_methods[i].isDefault) {
          _methods[i] = _methods[i].copyWith(isDefault: false);
        }
      }
    }

    _methods.add(PaymentMethodModel(
      id:             id,
      cardholderName: cardholderName.trim(),
      maskedNumber:   maskedNumber.trim(),
      expiryMonth:    expiryMonth.trim(),
      expiryYear:     expiryYear.trim(),
      network:        network,
      isDefault:      makeDefault || _methods.isEmpty,
    ));

    notifyListeners();
  }

  // ── Edit ──────────────────────────────────────────────────────────────────
  void editMethod({
    required String id,
    required String cardholderName,
    required String maskedNumber,
    required String expiryMonth,
    required String expiryYear,
    required CardNetwork network,
    bool makeDefault = false,
  }) {
    final idx = _methods.indexWhere((m) => m.id == id);
    if (idx < 0) return;

    if (makeDefault) {
      for (int i = 0; i < _methods.length; i++) {
        if (_methods[i].isDefault && i != idx) {
          _methods[i] = _methods[i].copyWith(isDefault: false);
        }
      }
    }

    _methods[idx] = _methods[idx].copyWith(
      cardholderName: cardholderName.trim(),
      maskedNumber:   maskedNumber.trim(),
      expiryMonth:    expiryMonth.trim(),
      expiryYear:     expiryYear.trim(),
      network:        network,
      isDefault:      makeDefault || _methods[idx].isDefault,
    );

    notifyListeners();
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  void deleteMethod(String id) {
    final wasDefault = _methods.any((m) => m.id == id && m.isDefault);
    _methods.removeWhere((m) => m.id == id);

    if (wasDefault && _methods.isNotEmpty) {
      _methods[0] = _methods[0].copyWith(isDefault: true);
    }

    notifyListeners();
  }

  // ── Set default ───────────────────────────────────────────────────────────
  void setDefault(String id) {
    for (int i = 0; i < _methods.length; i++) {
      _methods[i] = _methods[i].copyWith(isDefault: _methods[i].id == id);
    }
    notifyListeners();
  }
}
