import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  bool _isOnboardingCompleted = false;
  String _userName = '';
  String _userGoal = '';
  String _reminderFrequency = 'once_daily';
  bool _isPinEnabled = false;
  String _pin = '';
  bool _isDarkMode = false;
  bool _isInitialized = false;

  bool get isOnboardingCompleted => _isOnboardingCompleted;
  String get userName => _userName;
  String get userGoal => _userGoal;
  String get reminderFrequency => _reminderFrequency;
  bool get isPinEnabled => _isPinEnabled;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  AppSettingsProvider() {
    _loadSettingsSync();
  }

  void _loadSettingsSync() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      _userName = prefs.getString('user_name') ?? '';
      _userGoal = prefs.getString('user_goal') ?? '';
      _reminderFrequency = prefs.getString('reminder_frequency') ?? 'once_daily';
      _isPinEnabled = prefs.getBool('pin_enabled') ?? false;
      _pin = prefs.getString('pin') ?? '';
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding({
    required String userName,
    required String userGoal,
    required String reminderFrequency,
  }) async {
    _userName = userName;
    _userGoal = userGoal;
    _reminderFrequency = reminderFrequency;
    _isOnboardingCompleted = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('user_name', userName);
    await prefs.setString('user_goal', userGoal);
    await prefs.setString('reminder_frequency', reminderFrequency);

    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }

  Future<void> enablePin(String pin) async {
    _isPinEnabled = true;
    _pin = pin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pin_enabled', true);
    await prefs.setString('pin', pin);
    notifyListeners();
  }

  Future<void> disablePin() async {
    _isPinEnabled = false;
    _pin = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pin_enabled', false);
    await prefs.remove('pin');
    notifyListeners();
  }

  bool verifyPin(String enteredPin) {
    return _pin == enteredPin;
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }
}
