class MoodEntry {
  final String id;
  final String mood; // 'happy', 'sad', 'anxious', 'angry', 'tired', 'neutral'
  final int intensity; // 1-10
  final String? note;
  final DateTime timestamp;

  MoodEntry({
    String? id,
    required this.mood,
    required this.intensity,
    this.note,
    DateTime? timestamp,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'mood': mood,
    'intensity': intensity,
    'note': note,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    id: json['id'] as String,
    mood: json['mood'] as String,
    intensity: json['intensity'] as int,
    note: json['note'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  String getMoodEmoji() {
    const moodEmojis = {
      'happy': '😊',
      'sad': '😢',
      'anxious': '😰',
      'angry': '😠',
      'tired': '😴',
      'neutral': '😐',
    };
    return moodEmojis[mood] ?? '😐';
  }

  String getMoodText() {
    const moodTexts = {
      'happy': 'Радость',
      'sad': 'Грусть',
      'anxious': 'Тревога',
      'angry': 'Злость',
      'tired': 'Усталость',
      'neutral': 'Нейтрально',
    };
    return moodTexts[mood] ?? 'Неизвестно';
  }
}
