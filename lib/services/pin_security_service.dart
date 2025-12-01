import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinSecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _pinKey = 'app_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const int maxAttempts = 3;

  /// Проверяет, включена ли PIN защита
  Future<bool> isPinEnabled() async {
    try {
      final pin = await _secureStorage.read(key: _pinKey);
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      print('Error checking PIN enabled: $e');
      return false;
    }
  }

  /// Сохраняет PIN в безопасном хранилище
  Future<void> setPin(String pin) async {
    try {
      await _secureStorage.write(key: _pinKey, value: pin);
    } catch (e) {
      print('Error setting PIN: $e');
      throw Exception('Не удалось сохранить PIN');
    }
  }

  /// Проверяет правильность введенного PIN
  Future<bool> verifyPin(String enteredPin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey);
      return storedPin == enteredPin;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  /// Удаляет PIN
  Future<void> removePin() async {
    try {
      await _secureStorage.delete(key: _pinKey);
      await _secureStorage.delete(key: _biometricEnabledKey);
    } catch (e) {
      print('Error removing PIN: $e');
      throw Exception('Не удалось удалить PIN');
    }
  }

  /// Проверяет, доступна ли биометрия на устройстве
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Получает список доступных биометрических методов
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Проверяет, включена ли биометрия
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      print('Error checking biometric enabled: $e');
      return false;
    }
  }

  /// Включает/выключает биометрию
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      print('Error setting biometric enabled: $e');
      throw Exception('Не удалось изменить настройки биометрии');
    }
  }

  /// Аутентификация с помощью биометрии
  Future<bool> authenticateWithBiometric() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Подтвердите свою личность для доступа к Мире',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
}
