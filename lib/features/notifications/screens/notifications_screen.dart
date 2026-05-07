import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../services/firestore_service.dart';
import '../../../models/notification_model.dart';
import '../../auth/providers/auth_provider.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          userAsync.when(
            data: (user) => user?.isAdmin == true
                ? IconButton(
                    icon: const Icon(Icons.send),
                    tooltip: 'Send Notification',
                    onPressed: () => _showSendDialog(context, ref),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: notifAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: cs.outline),
                  const SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(color: cs.outline)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final n = notifications[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(
                      n.type == 'event' ? Icons.event : Icons.notifications,
                      color: cs.primary,
                    ),
                  ),
                  title: Text(n.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(n.body),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(n.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showSendDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty || bodyCtrl.text.isEmpty) return;
              await ref.read(firestoreServiceProvider).addNotification(
                    NotificationModel(
                      id: '',
                      title: titleCtrl.text.trim(),
                      body: bodyCtrl.text.trim(),
                      type: 'general',
                      createdAt: DateTime.now(),
                      isRead: false,
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
