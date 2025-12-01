import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../theme/app_theme.dart';
import 'pin_setup_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppSettingsProvider>();
    _nameController = TextEditingController(text: settings.userName);
    _goalController = TextEditingController(text: settings.userGoal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _saveName() {
    context.read<AppSettingsProvider>().setUserName(_nameController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Имя сохранено'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль и настройки'),
        elevation: 2,
      ),
      body: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Раздел профиля
                _buildSectionTitle('👤 Профиль'),
                const SizedBox(height: 12),
                _buildProfileCard(settingsProvider),
                const SizedBox(height: 32),

                // Раздел напоминаний
                _buildSectionTitle('🔔 Напоминания'),
                const SizedBox(height: 12),
                _buildRemindersSection(settingsProvider),
                const SizedBox(height: 32),

                // Раздел безопасности
                _buildSectionTitle('🔒 Безопасность'),
                const SizedBox(height: 12),
                _buildSecuritySection(),
                const SizedBox(height: 32),

                // Раздел информации
                _buildSectionTitle('ℹ️ О приложении'),
                const SizedBox(height: 12),
                _buildAboutSection(context),
                const SizedBox(height: 32),

                // Дисклеймер
                _buildDisclaimerSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildProfileCard(AppSettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Имя пользователя
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Имя',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.userName.isEmpty ? 'Не указано' : settings.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () => _showNameDialog(),
                ),
              ],
            ),
            const Divider(height: 24),
            // Цель использования
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Твоя цель',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.userGoal.isEmpty
                      ? 'Не выбрана'
                      : _getGoalText(settings.userGoal),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersSection(AppSettingsProvider settings) {
    const reminderOptions = {
      'once_daily': 'Один раз в день (вечер, 20:00)',
      'twice_daily': 'Два раза в день (утро 08:00, вечер 20:00)',
      'on_demand': 'Только по запросу',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Частота напоминаний',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...reminderOptions.entries.map((entry) {
              final isSelected = settings.reminderFrequency == entry.key;
              return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      // TODO: обновить напоминания
                    },
                    child: Row(
                      children: [
                        Radio<String>(
                          value: entry.key,
                          groupValue: settings.reminderFrequency,
                          onChanged: (_) {
                            // TODO: обновить напоминания
                          },
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Consumer<AppSettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Защита PIN-кодом',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Заблокировать приложение при запуске',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: settingsProvider.isPinEnabled,
                      onChanged: (value) {
                        if (value) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PinSetupScreen(),
                            ),
                          );
                        } else {
                          context.read<AppSettingsProvider>().disablePin();
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ночной режим',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Тёмная тема для глаз',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: settingsProvider.isDarkMode,
                      onChanged: (value) {
                        context.read<AppSettingsProvider>().toggleDarkMode(value);
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: const Text('Что умеет ИИ-ассистент'),
            trailing: const Icon(Icons.arrow_forward, color: AppColors.textLight),
            onTap: () => _showAboutDialog(context),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: const Text('Важно знать (дисклеймер)'),
            trailing: const Icon(Icons.arrow_forward, color: AppColors.textLight),
            onTap: () => _showDisclaimerDialog(context),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: const Text('Версия приложения'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.info, color: AppColors.textLight),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_outlined, color: AppColors.error),
              const SizedBox(width: 8),
              const Text(
                'Важный дисклеймер',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Это приложение предназначено для самопомощи и поддержки. '
                'Оно НЕ является медицинским сервисом и НЕ заменяет профессиональную психотерапию. '
                'ИИ-ассистент не может ставить диагнозы или назначать лечение. '
                '\n'
                'При наличии серьёзных психических проблем, суицидальных мыслей или острого кризиса '
                'немедленно обратись к психологу, психиатру или в службу экстренной помощи.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Как тебя зовут?'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Введи своё имя',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveName();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Что умеет ИИ-ассистент'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAboutItem(
                '💬',
                'Поддерживающий чат',
                'Слушает и отвечает мягко, используя техники КБТ и осознанности',
              ),
              _buildAboutItem(
                '📔',
                'Дневник эмоций',
                'Отслеживай свои чувства и их интенсивность каждый день',
              ),
              _buildAboutItem(
                '📊',
                'Аналитика',
                'Анализ настроений, тренды и рекомендации на неделю',
              ),
              _buildAboutItem(
                '🧘',
                'Упражнения',
                'Библиотека коротких упражнений на дыхание, осознанность и самоподдержку',
              ),
              _buildAboutItem(
                '🔒',
                'Конфиденциальность',
                'Все данные хранятся локально и защищены на твоём устройстве',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Важный дисклеймер'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '⚠️ Это НЕ медицинский сервис\n\n'
                    'Приложение создано для самопомощи и поддержки. '
                    'ИИ-ассистент не является врачом и не может:\n'
                    '✗ Ставить диагнозы\n'
                    '✗ Назначать лечение\n'
                    '✗ Заменить психотерапевта\n\n'
                    '🆘 Обратись к профессионалу, если:\n'
                    '• У тебя суицидальные мысли\n'
                    '• Ты хочешь причинить себе вред\n'
                    '• Ты находишься в остром кризисе\n'
                    '• Твоё состояние существенно не улучшается\n\n'
                    '📞 Горячие линии помощи:\n'
                    'Россия: 1-800-200-0-200\n'
                    'СНГ: найди в своей стране',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGoalText(String goal) {
    const goalsMap = {
      'anxiety': 'Уменьшить тревогу и беспокойство',
      'burnout': 'Справиться с выгоранием',
      'emotions': 'Лучше понимать свои эмоции',
      'support': 'Поддержка в трудный период',
    };
    return goalsMap[goal] ?? goal;
  }
}
