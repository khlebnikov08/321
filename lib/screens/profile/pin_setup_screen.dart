import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../theme/app_theme.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _firstPinController = TextEditingController();
  final _secondPinController = TextEditingController();
  int _step = 0; // 0 = первый ввод, 1 = подтверждение

  @override
  void dispose() {
    _firstPinController.dispose();
    _secondPinController.dispose();
    super.dispose();
  }

  void _setPin() {
    if (_firstPinController.text == _secondPinController.text &&
        _firstPinController.text.length == 4) {
      context
          .read<AppSettingsProvider>()
          .enablePin(_firstPinController.text);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PIN-код установлен'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (_firstPinController.text != _secondPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ PIN-коды не совпадают'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ PIN-код должен быть 4 цифры'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Установить PIN-код'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _step == 0 ? 'Введи PIN-код' : 'Подтверди PIN-код',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _step == 0
                  ? 'Используй 4 цифры'
                  : 'Введи PIN-код ещё раз',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 32),
            if (_step == 0) ...[
              TextField(
                controller: _firstPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, letterSpacing: 8),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  if (value.length == 4) {
                    setState(() => _step = 1);
                    _secondPinController.clear();
                  }
                },
              ),
            ] else ...[
              TextField(
                controller: _secondPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, letterSpacing: 8),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  if (value.length == 4) {
                    _setPin();
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                if (_step == 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _step = 0);
                        _firstPinController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      child: const Text('Назад'),
                    ),
                  ),
                if (_step == 1) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _setPin,
                    child: const Text('Установить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
