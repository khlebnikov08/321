import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pin_security_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  final PinSecurityService _pinService = PinSecurityService();

  bool _isOnboardingCompleted = false;
  String _userName = '';
  String _userGoal = '';
  String _reminderFrequency = 'once_daily';
  bool _isPinEnabled = false;
  bool _isDarkMode = false;
  bool _isInitialized = false;
  bool _isBiometricEnabled = false;

  bool get isOnboardingCompleted => _isOnboardingCompleted;
  String get userName => _userName;
  String get userGoal => _userGoal;
  String get reminderFrequency => _reminderFrequency;
  bool get isPinEnabled => _isPinEnabled;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;
  bool get isBiometricEnabled => _isBiometricEnabled;

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
      _isDarkMode = prefs.getBool('dark_mode') ?? false;

      // Проверяем PIN через сервис безопасности
      _isPinEnabled = await _pinService.isPinEnabled();
      _isBiometricEnabled = await _pinService.isBiometricEnabled();

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
    try {
      await _pinService.setPin(pin);
      _isPinEnabled = true;
      notifyListeners();
    } catch (e) {
      print('Error enabling PIN: $e');
      rethrow;
    }
  }

  Future<void> disablePin() async {
    try {
      await _pinService.removePin();
      _isPinEnabled = false;
      _isBiometricEnabled = false;
      notifyListeners();
    } catch (e) {
      print('Error disabling PIN: $e');
      rethrow;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _pinService.setBiometricEnabled(enabled);
      _isBiometricEnabled = enabled;
      notifyListeners();
    } catch (e) {
      print('Error setting biometric: $e');
      rethrow;
    }
  }

  Future<bool> isBiometricAvailable() async {
    return await _pinService.isBiometricAvailable();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }
}
