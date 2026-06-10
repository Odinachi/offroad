import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  late final SharedPreferences _prefs;

  final _darkModeKey = "isDarkMode";
  final _seenOnboardingKey = "seenOnboarding";
  final _huggingFaceTokenKey = "huggingFaceToken";
  final _inferenceEngineKey = "inferenceEngine";

  //Initialize
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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

  //Hugging Face Token
  Future<void> saveHuggingFaceToken(String value) async {
    await _prefs.setString(_huggingFaceTokenKey, value);
  }

  String? getHuggingFaceToken() {
    return _prefs.getString(_huggingFaceTokenKey);
  }

  //Inference Engine
  Future<void> saveInferenceEngine(String value) async {
    await _prefs.setString(_inferenceEngineKey, value);
  }

  String? getInferenceEngine() {
    return _prefs.getString(_inferenceEngineKey);
  }

  //clear all
  void clearAll() async {
    await _prefs.clear();
  }
}
