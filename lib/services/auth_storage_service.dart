import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Manages persistent authentication and biometric settings
class AuthStorageService {
  static final AuthStorageService _instance = AuthStorageService._internal();
  factory AuthStorageService() => _instance;
  AuthStorageService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Storage Keys
  static const _keyUsername = 'saved_username';
  static const _keyPassword = 'saved_password';
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyThemeMode = 'theme_mode';
  static const _keySessionToken = 'session_token'; // API session token (cookie)

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint('[AuthStorage] Biometric check error: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('[AuthStorage] Get biometrics error: $e');
      return [];
    }
  }

  /// Get friendly name for biometric type
  String getBiometricName(List<BiometricType> types) {
    if (types.isEmpty) return 'Biometrik';
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Parmaq izi';
    if (types.contains(BiometricType.iris)) return 'İris tanıma';
    if (types.contains(BiometricType.strong) || 
        types.contains(BiometricType.weak)) {
      return 'Biometrik doğrulama';
    }
    return 'Biometrik';
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final types = await getAvailableBiometrics();
      final biometricName = getBiometricName(types);
      
      return await _localAuth.authenticate(
        localizedReason: 'İDRAK Liseyi tətbiqinə daxil olmaq üçün $biometricName istifadə edin',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device PIN/Pattern as fallback
        ),
      );
    } catch (e) {
      debugPrint('[AuthStorage] Biometric auth error: $e');
      return false;
    }
  }

  /// Check if biometric is enabled for this user
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _keyBiometricEnabled);
      return value == 'true';
    } catch (e) {
      debugPrint('[AuthStorage] Read biometric setting error: $e');
      return false;
    }
  }

  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _keyBiometricEnabled,
        value: enabled.toString(),
      );
      debugPrint('[AuthStorage] Biometric ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('[AuthStorage] Save biometric setting error: $e');
    }
  }

  /// Save user credentials securely
  Future<void> saveCredentials(String username, String password) async {
    try {
      await _storage.write(key: _keyUsername, value: username);
      await _storage.write(key: _keyPassword, value: password);
      debugPrint('[AuthStorage] ✓ Credentials saved securely');
    } catch (e) {
      debugPrint('[AuthStorage] Save credentials error: $e');
    }
  }

  /// Get saved credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final username = await _storage.read(key: _keyUsername);
      final password = await _storage.read(key: _keyPassword);
      
      if (username != null && password != null) {
        return {'username': username, 'password': password};
      }
      return null;
    } catch (e) {
      debugPrint('[AuthStorage] Read credentials error: $e');
      return null;
    }
  }

  /// Check if credentials are saved
  Future<bool> hasStoredCredentials() async {
    final credentials = await getSavedCredentials();
    return credentials != null;
  }

  /// Clear all stored authentication data (logout)
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _keyUsername);
      await _storage.delete(key: _keyPassword);
      await _storage.delete(key: _keyBiometricEnabled);
      debugPrint('[AuthStorage] ✓ All auth data cleared');
    } catch (e) {
      debugPrint('[AuthStorage] Clear data error: $e');
    }
  }

  /// Persisted appearance preference ('light' / 'dark').
  /// Survives logout — it is a device-level setting, not per-account.
  Future<bool> getIsDarkMode() async {
    try {
      return await _storage.read(key: _keyThemeMode) == 'dark';
    } catch (e) {
      debugPrint('[AuthStorage] Read theme mode error: $e');
      return false;
    }
  }

  Future<void> saveIsDarkMode(bool dark) async {
    try {
      await _storage.write(key: _keyThemeMode, value: dark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('[AuthStorage] Save theme mode error: $e');
    }
  }

  /// Auto-login flow with biometric check
  /// Returns: [true] if should auto-login, [false] if manual login needed
  Future<bool> shouldAttemptAutoLogin() async {
    final hasCredentials = await hasStoredCredentials();
    if (!hasCredentials) {
      debugPrint('[AuthStorage] No credentials stored');
      return false;
    }

    final biometricEnabled = await isBiometricEnabled();
    debugPrint('[AuthStorage] Biometric enabled: $biometricEnabled');
    
    if (!biometricEnabled) {
      // Biometric disabled, require manual login
      debugPrint('[AuthStorage] Biometric disabled, manual login required');
      return false;
    }

    // Biometric enabled, require authentication
    debugPrint('[AuthStorage] Requesting biometric authentication...');
    final authenticated = await authenticateWithBiometrics();
    debugPrint('[AuthStorage] Biometric result: $authenticated');
    return authenticated;
  }

  // ========================================
  // 🌐 API SESSION TOKEN MANAGEMENT
  // ========================================
  
  /// Save API session token (cookie from web login)
  Future<void> saveSessionToken(String token) async {
    try {
      await _storage.write(key: _keySessionToken, value: token);
      debugPrint('[AuthStorage] ✓ Session token saved');
    } catch (e) {
      debugPrint('[AuthStorage] Save session token error: $e');
    }
  }

  /// Get saved session token
  Future<String?> getSessionToken() async {
    try {
      return await _storage.read(key: _keySessionToken);
    } catch (e) {
      debugPrint('[AuthStorage] Read session token error: $e');
      return null;
    }
  }

  /// Clear session token (logout from API)
  Future<void> clearSessionToken() async {
    try {
      await _storage.delete(key: _keySessionToken);
      debugPrint('[AuthStorage] ✓ Session token cleared');
    } catch (e) {
      debugPrint('[AuthStorage] Clear session token error: $e');
    }
  }
}
