import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/mood_entry.dart';

class MoodProvider extends ChangeNotifier {
  final List<MoodEntry> _entries = [];

  List<MoodEntry> get entries => _entries;

  MoodProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('mood_entries') ?? [];
      _entries.clear();
      for (var json in entriesJson) {
        final entry = MoodEntry.fromJson(jsonDecode(json));
        _entries.add(entry);
      }
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error loading mood entries: $e');
    }
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
      _entries.map((entry) => jsonEncode(entry.toJson())).toList();
      await prefs.setStringList('mood_entries', entriesJson);
    } catch (e) {
      print('Error saving mood entries: $e');
    }
  }

  /// Добавить запись о настроении
  Future<void> addMoodEntry(MoodEntry entry) async {
    _entries.add(entry);
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    await _saveEntries();
    notifyListeners();
  }

  /// Удалить запись
  Future<void> removeMoodEntry(String entryId) async {
    _entries.removeWhere((entry) => entry.id == entryId);
    await _saveEntries();
    notifyListeners();
  }

  /// Обновить запись
  Future<void> updateMoodEntry(String entryId, MoodEntry updatedEntry) async {
    final index = _entries.indexWhere((entry) => entry.id == entryId);
    if (index != -1) {
      _entries[index] = updatedEntry;
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await _saveEntries();
      notifyListeners();
    }
  }

  /// Получить записи за конкретный день
  /// Получить записи за конкретный день
  List<MoodEntry> getEntriesForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return _entries.where((entry) {
      final entryDateOnly = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      return entryDateOnly == dateOnly;
    }).toList();
  }


  /// Получить записи за неделю
  /// Получить записи за неделю
  List<MoodEntry> getEntriesForWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final startDateOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDateOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 6);

    return _entries.where((entry) {
      final entryDateOnly = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      return !entryDateOnly.isBefore(startDateOnly) &&
          !entryDateOnly.isAfter(endDateOnly);
    }).toList();
  }


  /// Получить доминирующее настроение за неделю
  String? getDominantMoodForWeek(DateTime date) {
    final weekEntries = getEntriesForWeek(date);
    if (weekEntries.isEmpty) return null;

    final moodCounts = <String, int>{};
    for (var entry in weekEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Получить статистику по настроениям за неделю
  Map<String, int> getMoodStatsForWeek(DateTime date) {
    final weekEntries = getEntriesForWeek(date);
    final stats = <String, int>{};

    for (var entry in weekEntries) {
      stats[entry.mood] = (stats[entry.mood] ?? 0) + 1;
    }

    return stats;
  }

  /// Получить среднюю интенсивность за неделю
  double getAverageIntensityForWeek(DateTime date) {
    final weekEntries = getEntriesForWeek(date);
    if (weekEntries.isEmpty) return 0;

    final totalIntensity =
    weekEntries.map((e) => e.intensity).reduce((a, b) => a + b);
    return totalIntensity / weekEntries.length;
  }
}
