// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  // ── Toggles ───────────────────────────────────────────────────────────────
  bool _darkMode      = true;
  bool _notifications = true;
  bool _emailUpdates  = false;
  bool _orderAlerts   = true;
  bool get darkMode      => _darkMode;
  bool get notifications => _notifications;
  bool get emailUpdates  => _emailUpdates;
  bool get orderAlerts   => _orderAlerts;

  void toggleDarkMode()      { _darkMode      = !_darkMode;      notifyListeners(); }
  void toggleNotifications() { _notifications = !_notifications; notifyListeners(); }
  void toggleEmailUpdates()  { _emailUpdates  = !_emailUpdates;  notifyListeners(); }
  void toggleOrderAlerts()   { _orderAlerts   = !_orderAlerts;   notifyListeners(); }

  // ── Language ───────────────────────────────────────────────────────────────
  static const List<String> languages = [
    'English', 'Sinhala', 'Tamil', 'French', 'Spanish', 'German',
    'Italian', 'Japanese', 'Chinese', 'Arabic',
  ];

  String _language = 'English';
  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  // ── Currency ───────────────────────────────────────────────────────────────
  static const List<String> currencies = [
    'USD (\$)', 'EUR (€)', 'GBP (£)',
    'JPY (¥)', 'CAD (C\$)', 'AUD (A\$)',
    'CHF (Fr)', 'LKR (RS)', 'INR (₹)',
  ];

  String _currency = 'USD (\$)';
  String get currency => _currency;

  void setCurrency(String currency) {
    _currency = currency;
    notifyListeners();
  }
}