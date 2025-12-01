import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../theme/app_theme.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late PageController _pageController;
  int _currentStep = 0;
  String _userName = '';
  String _userGoal = '';
  String _reminderFrequency = 'once_daily';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await context.read<AppSettingsProvider>().completeOnboarding(
      userName: _userName,
      userGoal: _userGoal,
      reminderFrequency: _reminderFrequency,
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  bool _isNextButtonEnabled() {
    switch (_currentStep) {
      case 0:
        return _userName.isNotEmpty;  // ← изменить на это
      case 1:
        return _userGoal.isNotEmpty;
      case 2:
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          _buildWelcomeScreen(),
          _buildGoalsScreen(),
          _buildRemindersScreen(),
          _buildPrivacyScreen(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return _OnboardingScreenTemplate(
      title: 'Добро пожаловать',
      emoji: '👋',
      children: [
        TextField(
          onChanged: (value) => setState(() => _userName = value),
          decoration: const InputDecoration(
            hintText: 'Как тебя зовут?',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Я Мира — твой ИИ-ассистент психолога.\n\n'
              'Здесь ты можешь безопасно говорить о своих чувствах и получать мягкую поддержку.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
      onNext: _nextPage,
      onPrevious: _previousPage,
      stepNumber: 1,
      totalSteps: 4,
      isNextEnabled: _userName.isNotEmpty,
    );
  }


  Widget _buildGoalsScreen() {
    return _OnboardingScreenTemplate(
      title: 'Что для тебя сейчас важнее?',
      emoji: '🎯',
      children: [
        _GoalOption(
          icon: '😰',
          label: 'Уменьшить тревогу и беспокойство',
          value: 'anxiety',
          groupValue: _userGoal,
          onChanged: (val) => setState(() => _userGoal = val ?? ''),
        ),
        _GoalOption(
          icon: '🔥',
          label: 'Справиться с выгоранием',
          value: 'burnout',
          groupValue: _userGoal,
          onChanged: (val) => setState(() => _userGoal = val ?? ''),
        ),
        _GoalOption(
          icon: '💭',
          label: 'Лучше понимать свои эмоции',
          value: 'emotions',
          groupValue: _userGoal,
          onChanged: (val) => setState(() => _userGoal = val ?? ''),
        ),
        _GoalOption(
          icon: '🤝',
          label: 'Поддержка в трудный период',
          value: 'support',
          groupValue: _userGoal,
          onChanged: (val) => setState(() => _userGoal = val ?? ''),
        ),
      ],
      onNext: _nextPage,
      onPrevious: _previousPage,
      stepNumber: 2,
      totalSteps: 4,
      isNextEnabled: _userGoal.isNotEmpty,
    );
  }

  Widget _buildRemindersScreen() {
    return _OnboardingScreenTemplate(
      title: 'Напоминания о заботе о себе',
      emoji: '🔔',
      children: [
        _ReminderOption(
          icon: '🌙',
          label: 'Один раз в день (вечер, 20:00)',
          value: 'once_daily',
          groupValue: _reminderFrequency,
          onChanged: (val) => setState(() => _reminderFrequency = val ?? ''),
        ),
        _ReminderOption(
          icon: '☀️',
          label: 'Два раза в день (8:00 и 20:00)',
          value: 'twice_daily',
          groupValue: _reminderFrequency,
          onChanged: (val) => setState(() => _reminderFrequency = val ?? ''),
        ),
        _ReminderOption(
          icon: '✋',
          label: 'Только по запросу',
          value: 'on_demand',
          groupValue: _reminderFrequency,
          onChanged: (val) => setState(() => _reminderFrequency = val ?? ''),
        ),
      ],
      onNext: _nextPage,
      onPrevious: _previousPage,
      stepNumber: 3,
      totalSteps: 4,
      isNextEnabled: true,
    );
  }

  Widget _buildPrivacyScreen() {
    return _OnboardingScreenTemplate(
      title: 'Конфиденциальность',
      emoji: '🔒',
      content:
      '✓ Твои записи и сообщения — только для тебя\n'
          '✓ Данные хранятся локально на устройстве\n'
          '✓ Не используются для рекламы\n'
          '✓ Защищены PIN/Face ID\n\n'
          'Это приложение не является медицинским сервисом.',
      onNext: _nextPage,
      onPrevious: _previousPage,
      stepNumber: 4,
      totalSteps: 4,
      isNextEnabled: true,
      isLast: true,
    );
  }
}

class _OnboardingScreenTemplate extends StatelessWidget {
  final String title;
  final String? emoji;
  final String? content;
  final List<Widget>? children;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int stepNumber;
  final int totalSteps;
  final bool isNextEnabled;
  final bool isLast;

  const _OnboardingScreenTemplate({
    required this.title,
    this.emoji,
    this.content,
    this.children,
    required this.onNext,
    required this.onPrevious,
    required this.stepNumber,
    required this.totalSteps,
    this.isNextEnabled = true,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Прогресс
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stepNumber / totalSteps,
                minHeight: 4,
                backgroundColor: AppColors.textLight.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 32),
            // Содержимое
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (emoji != null) ...[
                      Text(
                        emoji!,
                        style: const TextStyle(fontSize: 56),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (content != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        content!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (children != null) ...[
                      const SizedBox(height: 24),
                      ...children!,
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Кнопки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (stepNumber > 1)
                  ElevatedButton.icon(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Назад'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                  )
                else
                  const SizedBox(width: 100),
                ElevatedButton.icon(
                  onPressed: isNextEnabled ? onNext : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(isLast ? 'Начать' : 'Далее'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _GoalOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.background,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textLight.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderOption extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _ReminderOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.background,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textLight.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
