import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_session.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';

class ChatSidebar extends StatefulWidget {
  final VoidCallback onNewChat;
  final Function(String) onSelectChat;
  final String currentSessionId;

  const ChatSidebar({
    required this.onNewChat,
    required this.onSelectChat,
    required this.currentSessionId,
    super.key,
  });

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              right: BorderSide(
                color: AppColors.textLight.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Чаты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: widget.onNewChat,
                      tooltip: 'Новый чат',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Список чатов
              Expanded(
                child: chatProvider.chatSessions.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Нет чатов',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: chatProvider.chatSessions.length,
                  itemBuilder: (context, index) {
                    final session = chatProvider.chatSessions[index];
                    final isSelected =
                        session.id == widget.currentSessionId;

                    return _buildChatItem(
                      context,
                      session,
                      isSelected,
                      chatProvider,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatItem(
      BuildContext context,
      ChatSession session,
      bool isSelected,
      ChatProvider chatProvider,
      ) {
    return GestureDetector(
      onTap: () => widget.onSelectChat(session.id),
      onLongPress: () => _showChatMenu(context, session, chatProvider),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(
            Icons.chat_bubble_outline,
            color: isSelected ? AppColors.primary : AppColors.textLight,
            size: 20,
          ),
          title: Text(
            session.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textDark,
            ),
          ),
          subtitle: Text(
            _formatDate(session.lastMessageAt),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check, color: AppColors.primary, size: 18)
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          dense: true,
        ),
      ),
    );
  }

  void _showChatMenu(
      BuildContext context,
      ChatSession session,
      ChatProvider chatProvider,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                session.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Переименовать'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, session, chatProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                'Удалить',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirm(context, session, chatProvider);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context,
      ChatSession session,
      ChatProvider chatProvider,
      ) {
    final controller = TextEditingController(text: session.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Переименовать чат'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введи новое название',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              chatProvider.renameSession(session.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context,
      ChatSession session,
      ChatProvider chatProvider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              chatProvider.deleteSession(session.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}.${date.month}';
    }
  }
}
