import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CrisisAlertDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const CrisisAlertDialog({
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'С тобой всё не в порядке',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              '🆘',
              style: TextStyle(fontSize: 48),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Я заметил в твоём сообщении признаки того, что ты находишься в кризисе.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Я не могу помочь в такой ситуации. '
                  'Очень важно обратиться к живому человеку — психологу, психиатру или в службу помощи.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '📞 Горячие линии помощи',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildHotlineItem('Россия', '1-800-200-0-200'),
            _buildHotlineItem('Казахстан', '7-747-200-0-001'),
            _buildHotlineItem('Беларусь', '143'),
            _buildHotlineItem('Украина', '0-800-500-200'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onDismiss();
                Navigator.of(context).pop();
              },
              child: const Text('Я буду осторожен/на'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotlineItem(String country, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              country,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
