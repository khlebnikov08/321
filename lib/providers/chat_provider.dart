import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/message.dart';
import '../models/chat_session.dart';
import '../services/llm_service.dart';
import '../services/crisis_detection_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  final List<ChatSession> _chatSessions = [];
  String _currentSessionId = '';
  bool _isLoading = false;
  bool _hasCrisisAlert = false;

  List<Message> get messages => _messages;
  List<ChatSession> get chatSessions => _chatSessions;
  String get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  bool get hasCrisisAlert => _hasCrisisAlert;

  ChatProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadChatSessions();
    if (_chatSessions.isNotEmpty) {
      _currentSessionId = _chatSessions.first.id;
      await _loadMessagesForSession(_currentSessionId);
    } else {
      _createNewSession();
    }
    notifyListeners();
  }

  Future<void> _loadChatSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('chat_sessions') ?? [];
      _chatSessions.clear();
      for (var json in sessionsJson) {
        final session = ChatSession.fromJson(jsonDecode(json));
        _chatSessions.add(session);
      }
      _chatSessions.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    } catch (e) {
      print('Error loading chat sessions: $e');
    }
  }

  Future<void> _saveChatSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _chatSessions
          .map((session) => jsonEncode(session.toJson()))
          .toList();
      await prefs.setStringList('chat_sessions', sessionsJson);
    } catch (e) {
      print('Error saving chat sessions: $e');
    }
  }

  Future<void> _loadMessagesForSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList('chat_messages_$sessionId') ?? [];
      _messages.clear();
      for (var json in messagesJson) {
        final message = Message.fromJson(jsonDecode(json));
        _messages.add(message);
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _saveMessagesForSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson =
      _messages.map((msg) => jsonEncode(msg.toJson())).toList();
      await prefs.setStringList('chat_messages_$sessionId', messagesJson);

      // Обновляем metadata сессии
      final sessionIndex =
      _chatSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        final updatedSession = ChatSession(
          id: _chatSessions[sessionIndex].id,
          title: _chatSessions[sessionIndex].title,
          createdAt: _chatSessions[sessionIndex].createdAt,
          lastMessageAt: DateTime.now(),
          messageCount: _messages.length,
        );
        _chatSessions[sessionIndex] = updatedSession;
        await _saveChatSessions();
      }
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  void _createNewSession() {
    final newSession = ChatSession(
      title: 'Новый чат',
    );
    _currentSessionId = newSession.id;
    _messages.clear();
    _chatSessions.insert(0, newSession);
    notifyListeners();
  }

  void switchToSession(String sessionId) {
    _currentSessionId = sessionId;
    _loadMessagesForSession(sessionId);
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages_$sessionId');

    _chatSessions.removeWhere((session) => session.id == sessionId);
    await _saveChatSessions();

    if (_currentSessionId == sessionId) {
      if (_chatSessions.isNotEmpty) {
        _currentSessionId = _chatSessions.first.id;
        await _loadMessagesForSession(_currentSessionId);
      } else {
        _createNewSession();
      }
    }
    notifyListeners();
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    final sessionIndex = _chatSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex != -1) {
      final oldSession = _chatSessions[sessionIndex];
      final updatedSession = ChatSession(
        id: oldSession.id,
        title: newTitle,
        createdAt: oldSession.createdAt,
        lastMessageAt: oldSession.lastMessageAt,
        messageCount: oldSession.messageCount,
      );
      _chatSessions[sessionIndex] = updatedSession;
      await _saveChatSessions();
      notifyListeners();
    }
  }

  /// Добавить сообщение пользователя и получить ответ
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    // Проверяем, не кризис ли это
    if (CrisisDetectionService.detectCrisis(text)) {
      _hasCrisisAlert = true;
      notifyListeners();
      return;
    }

    // Если это первое сообщение в сессии, обновляем название
    if (_messages.isEmpty) {
      final title = text.length > 50 ? '${text.substring(0, 50)}...' : text;
      await renameSession(_currentSessionId, title);
    }

    // Добавляем сообщение пользователя
    _messages.add(
      Message(
        text: text,
        isUser: true,
      ),
    );
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      // Получаем ответ от LLM
      final response = await LLMService.generateResponse(text);

      // Добавляем ответ ассистента
      _messages.add(
        Message(
          text: response,
          isUser: false,
        ),
      );
    } catch (e) {
      // Добавляем сообщение об ошибке
      _messages.add(
        Message(
          text: 'Произошла ошибка. Пожалуйста, попробуйте ещё раз.',
          isUser: false,
        ),
      );
    }

    _isLoading = false;
    await _saveMessagesForSession(_currentSessionId);
    notifyListeners();
  }

  /// Сбросить флаг кризиса
  void dismissCrisisAlert() {
    _hasCrisisAlert = false;
    notifyListeners();
  }

  /// Очистить текущий чат
  Future<void> clearCurrentChat() async {
    await deleteSession(_currentSessionId);
  }
}
