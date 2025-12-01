import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../theme/app_theme.dart';
import 'exercise_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Упражнения'),
        elevation: 2,
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, exerciseProvider, _) {
          final categories = exerciseProvider.getCategories();
          final exercises = _selectedCategory == null
              ? exerciseProvider.exercises
              : exerciseProvider.getExercisesByCategory(_selectedCategory!);

          return Column(
            children: [
              // Фильтр по категориям
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedCategory == null
                                  ? AppColors.primary
                                  : AppColors.background,
                              border: Border.all(
                                color: _selectedCategory == null
                                    ? AppColors.primary
                                    : AppColors.textLight.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Все',
                              style: TextStyle(
                                color: _selectedCategory == null
                                    ? Colors.white
                                    : AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ...categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        final emoji = _getEmojiForCategory(category);
                        final text = _getTextForCategory(category);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.background,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textLight.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    text,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const Divider(),
              // Список упражнений
              Expanded(
                child: exercises.isEmpty
                    ? Center(
                  child: Text(
                    'Упражнения не найдены',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _buildExerciseCard(context, exercise);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ExerciseDetailScreen(exerciseId: exercise.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    exercise.getCategoryEmoji(),
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          exercise.description,
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⏱️ ${exercise.getDurationText()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.textLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmojiForCategory(String category) {
    const emojis = {
      'breathing': '🌬️',
      'mindfulness': '🧘',
      'self_support': '💪',
      'gratitude': '🙏',
    };
    return emojis[category] ?? '✨';
  }

  String _getTextForCategory(String category) {
    const texts = {
      'breathing': 'Дыхание',
      'mindfulness': 'Осознанность',
      'self_support': 'Поддержка',
      'gratitude': 'Благодарность',
    };
    return texts[category] ?? 'Упражнение';
  }
}
