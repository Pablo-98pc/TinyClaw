import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../store/database.dart';
import 'message_bubble.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageDao = ref.watch(messageDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Message>>(
        stream: messageDao.watchAllMessages(),
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Start chatting with TinyClaw', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              // Reverse order since ListView is reversed
              final message = messages[messages.length - 1 - index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MessageBubble(message: message),
              );
            },
          );
        },
      ),
    );
  }
}
