import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/pin_security_service.dart';

class PinEntryScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final bool allowBiometric;

  const PinEntryScreen({
    super.key,
    required this.onSuccess,
    this.allowBiometric = true,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen>
    with TickerProviderStateMixin {
  final PinSecurityService _pinService = PinSecurityService();
  String _enteredPin = '';
  int _attempts = 0;
  bool _isLocked = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  static const int maxAttempts = 3;
  static const int lockoutDuration = 30; // секунд

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    if (!widget.allowBiometric) return;

    final available = await _pinService.isBiometricAvailable();
    final enabled = await _pinService.isBiometricEnabled();

    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = enabled;
    });

    // Автоматически показываем биометрию при запуске
    if (available && enabled) {
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final authenticated = await _pinService.authenticateWithBiometric();
      if (authenticated) {
        widget.onSuccess();
      }
    } catch (e) {
      print('Biometric authentication error: $e');
    }
  }

  void _onNumberTap(String number) {
    if (_isLocked) return;
    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += number;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  Future<void> _verifyPin() async {
    final isCorrect = await _pinService.verifyPin(_enteredPin);

    if (isCorrect) {
      widget.onSuccess();
    } else {
      setState(() {
        _attempts++;
        _enteredPin = '';
      });

      // Анимация тряски
      _shakeController.forward(from: 0);

      if (_attempts >= maxAttempts) {
        _lockApp();
      } else {
        _showError('Неверный PIN. Осталось попыток: ${maxAttempts - _attempts}');
      }
    }
  }

  void _lockApp() {
    setState(() {
      _isLocked = true;
      _lockoutSeconds = lockoutDuration;
    });

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lockoutSeconds--;
      });

      if (_lockoutSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _attempts = 0;
        });
      }
    });

    _showError('Слишком много попыток. Повторите через $lockoutDuration секунд');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onBackspace() {
    if (_isLocked) return;
    if (_enteredPin.isEmpty) return;

    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Иконка приложения
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF21808D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // Заголовок
              Text(
                'Введите PIN',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLocked)
                Text(
                  'Заблокировано: $_lockoutSeconds сек',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
                )
              else
                Text(
                  'Для защиты ваших данных',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              const SizedBox(height: 48),
              // Индикатор PIN
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _enteredPin.length
                            ? const Color(0xFF21808D)
                            : theme.colorScheme.onBackground.withOpacity(0.2),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              // Цифровая клавиатура
              _buildNumberPad(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad(ThemeData theme) {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3'], theme),
        const SizedBox(height: 16),
        _buildNumberRow(['4', '5', '6'], theme),
        const SizedBox(height: 16),
        _buildNumberRow(['7', '8', '9'], theme),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка биометрии
            _buildActionButton(
              icon: Icons.fingerprint,
              onTap: (_biometricAvailable && _biometricEnabled && !_isLocked)
                  ? _authenticateWithBiometric
                  : null,
              theme: theme,
            ),
            const SizedBox(width: 24),
            // Кнопка 0
            _buildNumberButton('0', theme),
            const SizedBox(width: 24),
            // Кнопка удаления
            _buildActionButton(
              icon: Icons.backspace_outlined,
              onTap: _isLocked ? null : _onBackspace,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((number) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _buildNumberButton(number, theme),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number, ThemeData theme) {
    return InkWell(
      onTap: _isLocked ? null : () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isLocked
              ? theme.colorScheme.onBackground.withOpacity(0.05)
              : theme.colorScheme.onBackground.withOpacity(0.08),
        ),
        child: Center(
          child: Text(
            number,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: _isLocked
                  ? theme.colorScheme.onBackground.withOpacity(0.3)
                  : theme.colorScheme.onBackground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required ThemeData theme,
  }) {
    final isEnabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled
              ? theme.colorScheme.onBackground.withOpacity(0.08)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isEnabled
              ? theme.colorScheme.onBackground
              : theme.colorScheme.onBackground.withOpacity(0.2),
        ),
      ),
    );
  }
}
