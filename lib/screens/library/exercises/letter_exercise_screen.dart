import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/app_theme.dart';

class LetterExerciseScreen extends StatefulWidget {
  const LetterExerciseScreen({super.key});

  @override
  State<LetterExerciseScreen> createState() => _LetterExerciseScreenState();
}

class _LetterExerciseScreenState extends State<LetterExerciseScreen> {
  final _letterController = TextEditingController();
  final List<String> _savedLetters = [];
  bool _isViewingLetters = false;

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  @override
  void dispose() {
    _letterController.dispose();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    final prefs = await SharedPreferences.getInstance();
    final letters = prefs.getStringList('saved_letters') ?? [];
    setState(() => _savedLetters.addAll(letters));
  }

  Future<void> _saveLetter() async {
    if (_letterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Письмо не может быть пустым')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _savedLetters.add(_letterController.text);
    await prefs.setStringList('saved_letters', _savedLetters);

    _letterController.clear();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Письмо сохранено'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteLetter(int index) async {
    _savedLetters.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_letters', _savedLetters);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Письмо удалено')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✍️ Письмо самому себе'),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isViewingLetters ? Icons.edit : Icons.history),
            onPressed: () => setState(() => _isViewingLetters = !_isViewingLetters),
            tooltip: _isViewingLetters ? 'Написать письмо' : 'Мои письма',
          ),
        ],
      ),
      body: _isViewingLetters ? _buildLettersView() : _buildWritingView(),
    );
  }

  Widget _buildWritingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💌 Напиши письмо самому себе',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Представь, что ты пишешь письмо другу, который испытывает то же, что и ты. Дай себе советы, поддержку и любовь.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _letterController,
            minLines: 12,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Начни с "Милый я..."\n\nРасскажи о своих чувствах, дай себе советы, напомни о сильных сторонах.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveLetter,
              icon: const Icon(Icons.save),
              label: const Text('Сохранить письмо'),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ты можешь написать столько писем, сколько нужно. Все они сохранятся и ты сможешь их перечитывать в трудные моменты.',
                    style: const TextStyle(
                      fontSize: 12,
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
    );
  }

  Widget _buildLettersView() {
    if (_savedLetters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mail_outline,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет сохранённых писем',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Напиши первое письмо самому себе',
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedLetters.length,
      itemBuilder: (context, index) {
        final letter = _savedLetters[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '✉️ Письмо',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _deleteLetter(index),
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  letter,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('✉️ Твоё письмо'),
                        content: SingleChildScrollView(
                          child: Text(letter),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Закрыть'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  child: const Text('Прочитать полностью'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
