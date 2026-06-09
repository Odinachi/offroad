import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  late final SharedPreferences _prefs;

  final _darkModeKey = "isDarkMode";
  final _seenOnboardingKey = "seenOnboarding";

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

  //clear all
  void clearAll() async {
    await _prefs.clear();
  }
}
