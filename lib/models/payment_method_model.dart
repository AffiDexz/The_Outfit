// lib/models/payment_method_model.dart

enum CardNetwork { visa, mastercard, amex, other }

class PaymentMethodModel {
  final String id;
  final String cardholderName;
  final String maskedNumber; 
  final String expiryMonth; 
  final String expiryYear;  
  final CardNetwork network;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.cardholderName,
    required this.maskedNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.network,
    this.isDefault = false,
  });

  String get displayNumber => '•••• •••• •••• $maskedNumber';
  String get displayExpiry => '$expiryMonth / $expiryYear';

  /// Network label
  String get networkLabel {
    switch (network) {
      case CardNetwork.visa:       return 'Visa';
      case CardNetwork.mastercard: return 'Mastercard';
      case CardNetwork.amex:       return 'Amex';
      case CardNetwork.other:      return 'Card';
    }
  }

  PaymentMethodModel copyWith({
    String? cardholderName,
    String? maskedNumber,
    String? expiryMonth,
    String? expiryYear,
    CardNetwork? network,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id:             id,
      cardholderName: cardholderName ?? this.cardholderName,
      maskedNumber:   maskedNumber   ?? this.maskedNumber,
      expiryMonth:    expiryMonth    ?? this.expiryMonth,
      expiryYear:     expiryYear     ?? this.expiryYear,
      network:        network        ?? this.network,
      isDefault:      isDefault      ?? this.isDefault,
    );
  }
}
