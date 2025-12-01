class Exercise {
  final String id;
  final String title;
  final String description;
  final String category; // breathing, mindfulness, self_support, gratitude
  final int durationSeconds; // в секундах
  final String instruction;
  final List<String> steps;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationSeconds,
    required this.instruction,
    required this.steps,
  });

  String getCategoryEmoji() {
    const emojis = {
      'breathing': '🌬️',
      'mindfulness': '🧘',
      'self_support': '💪',
      'gratitude': '🙏',
    };
    return emojis[category] ?? '✨';
  }

  String getCategoryText() {
    const texts = {
      'breathing': 'Дыхательные техники',
      'mindfulness': 'Осознанность',
      'self_support': 'Самоподдержка',
      'gratitude': 'Благодарность',
    };
    return texts[category] ?? 'Упражнение';
  }

  String getDurationText() {
    if (durationSeconds < 60) {
      return '${durationSeconds}с';
    } else {
      final minutes = durationSeconds ~/ 60;
      return '${minutes}м';
    }
  }
}
