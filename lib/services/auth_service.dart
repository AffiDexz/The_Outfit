// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Current user ───────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Register ───────────────────────────────────────────────────────────────
  Future<UserCredential> register({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
  }) async {
    // 1. Create the Firebase Auth account
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 2. Update display name in Auth
    await credential.user!.updateDisplayName(fullName.trim());

    // 3. Save user profile in Firestore
    await _db.collection('users').doc(credential.user!.uid).set({
      'fullName':        fullName.trim(),
      'email':           email.trim(),
      'phone':           phone.trim(),
      'address':         '',
      'city':            '',
      'zip':             '',
      'profileImageUrl': '',
      'createdAt':       FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email:    email.trim(),
      password: password,
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() => _auth.signOut();

  // ── Change password ────────────────────────────────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser!;
    // Re-authenticate first
    final cred = EmailAuthProvider.credential(
      email:    user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  // ── Fetch user profile from Firestore ─────────────────────────────────────
  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Update user profile in Firestore ──────────────────────────────────────
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
