import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  late SharedPreferences _prefs;

  /// Keychain (iOS) / Keystore-backed storage (Android) for secrets.
  /// `first_unlock_this_device`: readable by background downloads after the
  /// first unlock, but never synced to iCloud or restored to another device.
  static const _secure = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final _darkModeKey = "isDarkMode";
  final _seenOnboardingKey = "seenOnboarding";
  final _huggingFaceTokenKey = "huggingFaceToken";
  final _inferenceEngineKey = "inferenceEngine";

  /// In-memory copy so callers can read the token synchronously.
  String? _huggingFaceToken;

  //Initialize
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // main() awaits this before runApp, so never let a stalled keychain
    // block launch.
    await _loadHuggingFaceToken().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('Secure storage timed out; using legacy token if any.');
        _huggingFaceToken = _prefs.getString(_huggingFaceTokenKey);
      },
    );
  }

  /// Reads the token from secure storage, moving a token saved in plain
  /// SharedPreferences by older versions into secure storage first.
  Future<void> _loadHuggingFaceToken() async {
    final legacy = _prefs.getString(_huggingFaceTokenKey);
    try {
      var token = await _secure.read(key: _huggingFaceTokenKey);
      if (legacy != null) {
        if (token == null && legacy.isNotEmpty) {
          await _secure.write(key: _huggingFaceTokenKey, value: legacy);
          token = legacy;
        }
        await _prefs.remove(_huggingFaceTokenKey);
      }
      _huggingFaceToken = token;
    } catch (e) {
      // Secure storage unavailable (e.g. no plugin under `flutter test`):
      // keep using what we have in memory, and leave any legacy value where
      // it is rather than lose it.
      debugPrint('Secure storage unavailable: $e');
      _huggingFaceToken = legacy;
    }
  }

  //Dark mode
  Future<void> saveIsDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
  }

  bool? getIsDarkMode() {
    return _prefs.getBool(_darkModeKey);
  }

  //Onboarding
  Future<void> saveSeenOnboarding() async {
    await _prefs.setBool(_seenOnboardingKey, true);
  }

  bool getSeenOnboarding() {
    return _prefs.getBool(_seenOnboardingKey) ?? false;
  }

  //Hugging Face Token — stored in secure storage, never in SharedPreferences.
  /// Saves [value], or removes the token when it's empty.
  Future<void> saveHuggingFaceToken(String value) async {
    _huggingFaceToken = value.isEmpty ? null : value;
    try {
      if (value.isEmpty) {
        await _secure.delete(key: _huggingFaceTokenKey);
      } else {
        await _secure.write(key: _huggingFaceTokenKey, value: value);
      }
    } catch (e) {
      debugPrint('Secure storage unavailable; token kept in memory only: $e');
    }
  }

  String? getHuggingFaceToken() => _huggingFaceToken;

  //Inference Engine
  Future<void> saveInferenceEngine(String value) async {
    await _prefs.setString(_inferenceEngineKey, value);
  }

  String? getInferenceEngine() {
    return _prefs.getString(_inferenceEngineKey);
  }

  //clear all
  Future<void> clearAll() async {
    _huggingFaceToken = null;
    await _prefs.clear();
    try {
      await _secure.delete(key: _huggingFaceTokenKey);
    } catch (e) {
      debugPrint('Secure storage unavailable: $e');
    }
  }
}
