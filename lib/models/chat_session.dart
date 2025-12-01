class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final int messageCount;

  ChatSession({
    String? id,
    required this.title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    this.messageCount = 0,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        lastMessageAt = lastMessageAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'lastMessageAt': lastMessageAt.toIso8601String(),
    'messageCount': messageCount,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    title: json['title'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
    messageCount: json['messageCount'] as int? ?? 0,
  );
}
