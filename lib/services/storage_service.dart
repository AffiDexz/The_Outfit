// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a profile image and return the download URL
  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');
    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  /// Upload a product image (for admin use in Phase 2)
  Future<String> uploadProductImage({
    required String productId,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('product_images/$productId.jpg');
    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  /// Delete a file from Storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // File may not exist — ignore
    }
  }
}
