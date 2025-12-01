import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчёты'),
        elevation: 2,
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, _) {
          final weekEntries = moodProvider.getEntriesForWeek(_weekStart);
          final stats = moodProvider.getMoodStatsForWeek(_weekStart);
          final dominantMood = moodProvider.getDominantMoodForWeek(_weekStart);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Переключение недель
                _buildWeekSelector(),
                const SizedBox(height: 24),

                // Статус (если нет данных)
                if (weekEntries.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.insights_outlined,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Нет данных за эту неделю',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Добавь записи в дневник эмоций,\nчтобы увидеть аналитику',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Доминирующее настроение
                  if (dominantMood != null)
                    _buildDominantMoodCard(dominantMood),
                  const SizedBox(height: 24),

                  // График настроений
                  _buildMoodTrendChart(weekEntries),
                  const SizedBox(height: 24),

                  // Статистика по эмоциям
                  _buildMoodStats(stats),
                  const SizedBox(height: 24),

                  // Тригеры (часто упоминаемые темы)
                  _buildTriggers(weekEntries),
                  const SizedBox(height: 24),

                  // Рекомендации
                  _buildRecommendations(stats),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekSelector() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousWeek,
          color: AppColors.primary,
        ),
        Expanded(
          child: Text(
            '${_formatDate(_weekStart)} — ${_formatDate(weekEnd)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextWeek,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDominantMoodCard(String dominantMood) {
    final moodData = {
      'happy': {'emoji': '😊', 'text': 'Радость'},
      'sad': {'emoji': '😢', 'text': 'Грусть'},
      'anxious': {'emoji': '😰', 'text': 'Тревога'},
      'angry': {'emoji': '😠', 'text': 'Злость'},
      'tired': {'emoji': '😴', 'text': 'Усталость'},
      'neutral': {'emoji': '😐', 'text': 'Нейтрально'},
    };

    final mood = moodData[dominantMood];

    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              mood?['emoji'] ?? '😐',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Доминирующее настроение',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mood?['text'] ?? 'Неизвестно',
                  style: const TextStyle(
                    fontSize: 18,
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

  Widget _buildMoodTrendChart(List<MoodEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тренд настроения',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Упрощённый график (средняя интенсивность в день)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final day = DateTime.now()
                        .subtract(Duration(days: 6 - index))
                        .toDateOnly();
                    final dayEntries = entries
                        .where((e) => e.timestamp.toDateOnly() == day)
                        .toList();

                    final avgIntensity = dayEntries.isEmpty
                        ? 0.0
                        : dayEntries
                        .map((e) => e.intensity)
                        .reduce((a, b) => a + b) /
                        dayEntries.length;

                    return Column(
                      children: [
                        Container(
                          width: 30,
                          height: (avgIntensity / 10) * 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDayName(day),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodStats(Map<String, int> stats) {
    const moodEmojis = {
      'happy': '😊',
      'sad': '😢',
      'anxious': '😰',
      'angry': '😠',
      'tired': '😴',
      'neutral': '😐',
    };

    const moodTexts = {
      'happy': 'Радость',
      'sad': 'Грусть',
      'anxious': 'Тревога',
      'angry': 'Злость',
      'tired': 'Усталость',
      'neutral': 'Нейтрально',
    };

    final weekEntries = context.read<MoodProvider>().getEntriesForWeek(_weekStart);
    final avgIntensity = weekEntries.isEmpty
        ? 0.0
        : weekEntries.map((e) => e.intensity).reduce((a, b) => a + b) /
        weekEntries.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Статистика эмоций',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Средняя интенсивность за неделю
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Средняя интенсивность за неделю',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${avgIntensity.toStringAsFixed(1)}/10',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: avgIntensity / 10,
                            minHeight: 8,
                            backgroundColor: AppColors.textLight.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getIntensityText(avgIntensity),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 Интенсивность показывает, насколько сильно ты чувствуешь эмоцию. Это помогает увидеть, становится ли тебе лучше или хуже.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Список эмоций
        ...stats.entries.map((entry) {
          final mood = entry.key;
          final count = entry.value;
          final emoji = moodEmojis[mood] ?? '😐';
          final text = moodTexts[mood] ?? 'Неизвестно';

          // Средняя интенсивность для этой эмоции
          final moodEntries =
          weekEntries.where((e) => e.mood == mood).toList();
          final avgMoodIntensity = moodEntries.isEmpty
              ? 0.0
              : moodEntries.map((e) => e.intensity).reduce((a, b) => a + b) /
              moodEntries.length;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Среднее: ${avgMoodIntensity.toStringAsFixed(1)}/10',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: avgMoodIntensity / 10,
                          minHeight: 4,
                          backgroundColor: AppColors.textLight.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count раз',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getIntensityText(double intensity) {
    if (intensity <= 3) {
      return 'Слабое проявление эмоций';
    } else if (intensity <= 6) {
      return 'Среднее проявление эмоций';
    } else {
      return 'Сильное проявление эмоций';
    }
  }


  Widget _buildTriggers(List<MoodEntry> entries) {
    final notes = entries
        .where((e) => e.note != null && e.note!.isNotEmpty)
        .map((e) => e.note!)
        .toList();

    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Простой анализ: извлекаем ключевые слова
    final keywords = <String, int>{};
    final triggerWords = [
      'работа',
      'работу',
      'отношение',
      'отношений',
      'семья',
      'семьи',
      'друг',
      'друзья',
      'здоровье',
      'здоровьем',
      'деньги',
      'денег',
      'финанс',
      'начальник',
      'стресс',
      'давление',
      'усталость',
      'сон',
    ];

    for (var note in notes) {
      for (var word in triggerWords) {
        if (note.toLowerCase().contains(word)) {
          keywords[word] = (keywords[word] ?? 0) + 1;
        }
      }
    }

    if (keywords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Частые темы',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.entries
              .toList()
              .asMap()
              .entries
              .take(5)
              .map((entry) {
            final keyword = entry.value.key;
            final count = entry.value.value;

            return Chip(
              label: Text('$keyword ($count)'),
              backgroundColor: AppColors.accent.withOpacity(0.2),
              labelStyle: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendations(Map<String, int> stats) {
    String getRecommendation() {
      if (stats.isEmpty) {
        return 'Добавляй записи в дневник, чтобы получить персональные рекомендации.';
      }

      final maxMood = stats.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      if (maxMood == 'anxious' || maxMood == 'angry') {
        return 'Попробуй дыхательные упражнения — они помогут снизить уровень беспокойства.';
      } else if (maxMood == 'tired') {
        return 'Тебе может помочь осознанное сканирование тела и упражнение на благодарность.';
      } else if (maxMood == 'sad') {
        return 'Письмо самому себе и техника самообъятия могут улучшить настроение.';
      } else {
        return 'Продолжай отслеживать свои эмоции. Регулярная рефлексия укрепляет психическое здоровье.';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Рекомендации',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: AppColors.accent.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    getRecommendation(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}';
  }

  String _getDayName(DateTime date) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[date.weekday - 1];
  }
}

// Расширение для удобства
extension DateOnly on DateTime {
  DateTime toDateOnly() {
    return DateTime(year, month, day);
  }
}
