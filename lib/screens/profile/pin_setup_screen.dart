import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _enteredPin = '';
  String _confirmedPin = '';
  int _step = 0; // 0 = первый ввод, 1 = подтверждение
  bool _biometricAvailable = false;
  bool _enableBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final settings = context.read<AppSettingsProvider>();
    final available = await settings.isBiometricAvailable();
    setState(() {
      _biometricAvailable = available;
    });
  }

  void _onNumberTap(String number) {
    if (_step == 0) {
      if (_enteredPin.length < 4) {
        setState(() {
          _enteredPin += number;
        });
        if (_enteredPin.length == 4) {
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _step = 1;
            });
          });
        }
      }
    } else if (_step == 1) {
      if (_confirmedPin.length < 4) {
        setState(() {
          _confirmedPin += number;
        });
        if (_confirmedPin.length == 4) {
          _verifyAndSetPin();
        }
      }
    }
  }

  void _onBackspace() {
    setState(() {
      if (_step == 0 && _enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      } else if (_step == 1 && _confirmedPin.isNotEmpty) {
        _confirmedPin = _confirmedPin.substring(0, _confirmedPin.length - 1);
      }
    });
  }

  Future<void> _verifyAndSetPin() async {
    if (_enteredPin == _confirmedPin) {
      try {
        final settings = context.read<AppSettingsProvider>();
        await settings.enablePin(_enteredPin);

        // Если биометрия доступна и включена
        if (_biometricAvailable && _enableBiometric) {
          await settings.setBiometricEnabled(true);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ PIN-код установлен'),
              backgroundColor: Color(0xFF21808D),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Ошибка: ${e.toString()}'),
              backgroundColor: Colors.red.shade600,
            ),
          );
          setState(() {
            _step = 0;
            _enteredPin = '';
            _confirmedPin = '';
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ PIN-коды не совпадают'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      setState(() {
        _step = 0;
        _enteredPin = '';
        _confirmedPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPin = _step == 0 ? _enteredPin : _confirmedPin;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Установить PIN-код'),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Иконка
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF21808D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // Заголовок
              Text(
                _step == 0 ? 'Введите PIN-код' : 'Подтвердите PIN',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _step == 0
                    ? 'Используйте 4 цифры'
                    : 'Введите PIN-код ещё раз',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 48),
              // Индикатор PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < currentPin.length
                          ? const Color(0xFF21808D)
                          : theme.colorScheme.onBackground.withOpacity(0.2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Опция биометрии
              if (_biometricAvailable && _step == 0)
                CheckboxListTile(
                  title: Text(
                    'Использовать Face ID / Touch ID',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: _enableBiometric,
                  onChanged: (value) {
                    setState(() {
                      _enableBiometric = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF21808D),
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
            const SizedBox(width: 72), // Пустое место
            const SizedBox(width: 24),
            _buildNumberButton('0', theme),
            const SizedBox(width: 24),
            _buildActionButton(
              icon: Icons.backspace_outlined,
              onTap: _onBackspace,
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
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.onBackground.withOpacity(0.08),
        ),
        child: Center(
          child: Text(
            number,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.onBackground.withOpacity(0.08),
        ),
        child: Icon(
          icon,
          size: 28,
          color: theme.colorScheme.onBackground,
        ),
      ),
    );
  }
}
