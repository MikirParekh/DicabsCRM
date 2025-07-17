import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

class SecureStorageService {
  // Singleton instance for global access
  static final SecureStorageService _instance = SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  // Private constructor for singleton pattern
  SecureStorageService._internal();

  // FlutterSecureStorage instance
  late FlutterSecureStorage _storage;

  // Initialize only for mobile platforms (Android & iOS)
  Future<void> init() async {
    if (Platform.isAndroid || Platform.isIOS) {
      _storage = const FlutterSecureStorage();
    }
  }

  // Create or Update value in storage
  Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read value from storage
  Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }

  // Delete value from storage
  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all data in storage
  Future<void> clearStorage() async {
    await _storage.deleteAll();
  }
}
