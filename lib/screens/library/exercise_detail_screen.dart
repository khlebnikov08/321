import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../theme/app_theme.dart';
import 'exercises/letter_exercise_screen.dart';


class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({
    required this.exerciseId,
    super.key,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _isStarted = false;
  int _currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Упражнение'),
        elevation: 2,
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, exerciseProvider, _) {
          final exercise = exerciseProvider.getExerciseById(widget.exerciseId);

          if (exercise == null) {
            return const Center(child: Text('Упражнение не найдено'));
          }

          if (_isStarted) {
            return _buildExerciseView(exercise);
          } else {
            return _buildPreview(exercise);
          }
        },
      ),
    );
  }

  Widget _buildPreview(Exercise exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и эмодзи
          Row(
            children: [
              Text(
                exercise.getCategoryEmoji(),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      exercise.getCategoryText(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Информация
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text(
                      exercise.getDurationText(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.list, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.steps.length} шагов',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Описание
          const Text(
            'О упражнении',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),

          // Инструкция
          const Text(
            'Инструкция',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.instruction,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),
          if (exercise.id == '5') // Письмо самому себе
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LetterExerciseScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Начать упражнение'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
              ),
            )
          else
          // Кнопка начала
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isStarted = true;
                  _currentStepIndex = 0;
                });
              },
              child: const Text('Начать упражнение'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseView(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Прогресс
          Text(
            'Шаг ${_currentStepIndex + 1}/${exercise.steps.length}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentStepIndex + 1) / exercise.steps.length,
              minHeight: 6,
              backgroundColor: AppColors.textLight.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 48),

          // Эмодзи и название упражнения
          Text(
            exercise.getCategoryEmoji(),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            exercise.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 48),

          // Текущий шаг
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Шаг ${_currentStepIndex + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  exercise.steps[_currentStepIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Кнопки навигации
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStepIndex > 0)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _currentStepIndex--);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Назад'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                )
              else
                const SizedBox(width: 100),
              if (_currentStepIndex < exercise.steps.length - 1)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _currentStepIndex++);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Дальше'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isStarted = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Упражнение завершено!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Завершить'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
