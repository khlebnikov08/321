import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';
import '../../theme/app_theme.dart';

class MoodCheckinDialog extends StatefulWidget {
  const MoodCheckinDialog({super.key});

  @override
  State<MoodCheckinDialog> createState() => _MoodCheckinDialogState();
}

class _MoodCheckinDialogState extends State<MoodCheckinDialog> {
  String _selectedMood = 'neutral';
  int _intensity = 5;
  final _noteController = TextEditingController();
  late DateTime _selectedDate;

  final _moods = [
    {'key': 'happy', 'emoji': '😊', 'text': 'Радость'},
    {'key': 'sad', 'emoji': '😢', 'text': 'Грусть'},
    {'key': 'anxious', 'emoji': '😰', 'text': 'Тревога'},
    {'key': 'angry', 'emoji': '😠', 'text': 'Злость'},
    {'key': 'tired', 'emoji': '😴', 'text': 'Усталость'},
    {'key': 'neutral', 'emoji': '😐', 'text': 'Нейтрально'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveMoodEntry() {
    // Создаём запись с выбранной датой И временем
    final now = DateTime.now();
    final entry = MoodEntry(
      mood: _selectedMood,
      intensity: _intensity,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      timestamp: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,  // Сохраняем текущее время
        now.minute,
      ),
    );

    context.read<MoodProvider>().addMoodEntry(entry);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Запись за ${_formatDate(_selectedDate)} сохранена',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Сегодня';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Вчера';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              const Text(
                'Как ты себя чувствуешь?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Выбор даты
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textLight.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Дата: ${_formatDate(_selectedDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Выбор эмоции
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  final isSelected = _selectedMood == mood['key'];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood['key']!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.background,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textLight.withOpacity(0.2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood['emoji']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood['text']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Шкала интенсивности
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Насколько сильно?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_intensity/10',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _intensity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.textLight.withOpacity(0.2),
                    onChanged: (value) {
                      setState(() => _intensity = value.toInt());
                    },
                  ),
                  // Объяснение интенсивности
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getIntensityExplanation(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Поле для заметки
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Что случилось? (необязательно)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveMoodEntry,
                      child: const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getIntensityExplanation() {
    if (_intensity <= 3) {
      return 'Слабое проявление эмоции — ты относительно спокоен';
    } else if (_intensity <= 6) {
      return 'Среднее проявление — эмоция заметна, но управляема';
    } else {
      return 'Сильное проявление — эмоция интенсивная и требует внимания';
    }
  }
}
