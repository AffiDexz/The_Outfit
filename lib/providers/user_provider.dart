// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService       _authService      = AuthService();
  final FirestoreService  _firestoreService = FirestoreService();

  UserModel?          _user;
  bool                _loading     = false;
  String?             _error;
  List<OrderModel>    _orders      = [];
  int                 _reviewCount = 0;

  // ── Getters ───────────────────────────────────────────────────────────────
  UserModel?       get user         => _user;
  bool             get isLoggedIn   => _authService.currentUser != null;
  bool             get loading      => _loading;
  String?          get error        => _error;
  List<OrderModel> get orders       => List.unmodifiable(_orders);
  int              get orderCount   => _orders.length;
  int              get reviewCount  => _reviewCount;
  String?          get uid          => _authService.currentUser?.uid;

  // ── Initialize on app start ────────────────────────────────────────────────
  // Call this in main.dart after Firebase.initializeApp()
  Future<void> init() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return;
    await _loadProfile(firebaseUser.uid);
    _listenOrders(firebaseUser.uid);
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
  }) async {
    _setLoading(true);
    try {
      final cred = await _authService.register(
        fullName: fullName,
        email:    email,
        password: password,
        phone:    phone,
      );
      await _loadProfile(cred.user!.uid);
      _listenOrders(cred.user!.uid);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      _setLoading(false);
      return false;
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final cred = await _authService.login(email: email, password: password);
      await _loadProfile(cred.user!.uid);
      _listenOrders(cred.user!.uid);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      _setLoading(false);
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _user        = null;
    _orders      = [];
    _reviewCount = 0;
    notifyListeners();
  }

  // ── Load profile from Firestore ────────────────────────────────────────────
  Future<void> _loadProfile(String uid) async {
    final data = await _authService.fetchUserProfile(uid);
    if (data != null) {
      _user = UserModel(
        fullName: data['fullName'] ?? '',
        email:    data['email']    ?? '',
        phone:    data['phone']    ?? '',
        address:  data['address']  ?? '',
        city:     data['city']     ?? '',
        zip:      data['zip']      ?? '',
        profileImageUrl: data['profileImageUrl'] ?? '',
      );
      notifyListeners();
    }
  }

  // ── Update profile ─────────────────────────────────────────────────────────
  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? zip,
    String? profileImageUrl,
  }) async {
    if (uid == null || _user == null) return;
    final updates = <String, dynamic>{};
    if (fullName        != null) updates['fullName']        = fullName;
    if (email           != null) updates['email']           = email;
    if (phone           != null) updates['phone']           = phone;
    if (address         != null) updates['address']         = address;
    if (city            != null) updates['city']            = city;
    if (zip             != null) updates['zip']             = zip;
    if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

    await _authService.updateUserProfile(uid!, updates);
    _user = _user!.copyWith(
      fullName:        fullName,
      email:           email,
      phone:           phone,
      address:         address,
      city:            city,
      zip:             zip,
      profileImageUrl: profileImageUrl,
    );
    notifyListeners();
  }

  // ── Orders live stream ─────────────────────────────────────────────────────
  void _listenOrders(String uid) {
    _firestoreService.ordersStream(uid).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  // ── Place order (called from CheckoutScreen) ───────────────────────────────
  Future<String?> placeOrder({
    required items,
    required double total,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    if (uid == null) return null;
    return _firestoreService.placeOrder(
      uid:             uid!,
      items:           items,
      total:           total,
      deliveryAddress: deliveryAddress,
      paymentMethod:   paymentMethod,
    );
  }

  void addReview() {
    _reviewCount++;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'This email is already registered.';
      case 'invalid-email':        return 'Invalid email address.';
      case 'weak-password':        return 'Password is too weak.';
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password.';
      case 'too-many-requests':    return 'Too many attempts. Try again later.';
      default:                     return 'Something went wrong. Please try again.';
    }
  }
}
