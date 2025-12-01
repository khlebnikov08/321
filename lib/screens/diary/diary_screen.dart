import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';
import '../../theme/app_theme.dart';
import 'mood_checkin_dialog.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  void _showMoodCheckinDialog() {
    showDialog(
      context: context,
      builder: (context) => const MoodCheckinDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневник эмоций'),
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMoodCheckinDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, _) {
          return Column(
            children: [
              // Календарь
              Padding(
                padding: const EdgeInsets.all(16),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2026, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: AppColors.textLight),
                    defaultTextStyle: const TextStyle(color: AppColors.textDark),
                    outsideTextStyle: const TextStyle(color: AppColors.textLight),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(Icons.chevron_left),
                    rightChevronIcon: Icon(Icons.chevron_right),
                  ),
                ),
              ),
              const Divider(),
              // Записи выбранного дня
              Expanded(
                child: _buildSelectedDayEntries(moodProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayEntries(MoodProvider moodProvider) {
    //final dayEntries = moodProvider.getEntriesForDate(_selectedDay);
    // Убедись, что дневник показывает записи правильно:
    final entriesForDay = context.read<MoodProvider>().getEntriesForDate(_selectedDay);

    if (entriesForDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_satisfied_alt_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет записей на ${_formatDate(_selectedDay)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Нажми кнопку + и добавь первую запись',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: entriesForDay.length,
      itemBuilder: (context, index) {
        final entry = entriesForDay[index];
        return _buildMoodEntryCard(context, entry, moodProvider);
      },
    );
  }

  Widget _buildMoodEntryCard(
      BuildContext context,
      MoodEntry entry,
      MoodProvider moodProvider,
      ) {
    return Dismissible(
      key: Key(entry.id),
      onDismissed: (_) {
        moodProvider.removeMoodEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запись удалена')),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.getMoodEmoji(),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.getMoodText(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Интенсивность: ${entry.intensity}/10',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    _formatTime(entry.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              if (entry.note != null && entry.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.note!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    if (isSameDay(dateTime, now)) {
      return 'Сегодня';
    } else if (isSameDay(dateTime, now.subtract(const Duration(days: 1)))) {
      return 'Вчера';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }
}
