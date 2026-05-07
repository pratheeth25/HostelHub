import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../services/firestore_service.dart';
import '../../../models/event_model.dart';
import '../../../models/registration_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../../../widgets/shimmer_list.dart';
import 'package:uuid/uuid.dart';

final _eventDetailProvider = StreamProvider.family<EventModel?, String>((ref, id) {
  return ref.watch(firestoreServiceProvider).getAllEvents().map(
    (events) => events.where((e) => e.id == id).firstOrNull,
  );
});

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(_eventDetailProvider(eventId));
    final userAsync = ref.watch(currentUserProvider);
    final isRegisteredAsync = ref.watch(isRegisteredProvider(eventId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const Center(child: Text('Event not found'));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(event.title,
                      style: const TextStyle(shadows: [Shadow(blurRadius: 4)])),
                  background: event.bannerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: event.bannerUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: cs.primaryContainer),
                          errorWidget: (_, __, ___) =>
                              Container(color: cs.primaryContainer),
                        )
                      : Container(
                          color: cs.primaryContainer,
                          child: Icon(Icons.event, size: 80, color: cs.primary),
                        ),
                ),
                actions: [
                  userAsync.when(
                    data: (user) => user?.isAdmin == true
                        ? PopupMenuButton(
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit Event')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Delete Event')),
                              const PopupMenuItem(
                                  value: 'attendance',
                                  child: Text('Mark Attendance')),
                            ],
                            onSelected: (val) async {
                              if (val == 'edit') {
                                context.push('/edit-event/${event.id}');
                              } else if (val == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Event'),
                                    content: const Text(
                                        'Are you sure you want to delete this event?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel')),
                                      FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref
                                      .read(firestoreServiceProvider)
                                      .deleteEvent(event.id);
                                  if (context.mounted) context.pop();
                                }
                              } else if (val == 'attendance') {
                                context.push('/attendance/${event.id}');
                              }
                            },
                          )
                        : const SizedBox(),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _InfoRow(
                        icon: Icons.calendar_month,
                        text: DateFormat('EEEE, MMM d, y • h:mm a')
                            .format(event.dateTime)),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.location_on, text: event.venue),
                    const SizedBox(height: 8),
                    _InfoRow(
                        icon: Icons.people,
                        text:
                            '${event.registeredCount} / ${event.participantLimit} registered'),
                    const SizedBox(height: 8),
                    _InfoRow(
                        icon: Icons.person, text: 'By ${event.organizerName}'),
                    const SizedBox(height: 20),
                    Text('About',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(event.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const ShimmerList(count: 5),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: eventAsync.when(
        data: (event) {
          if (event == null) return null;
          return userAsync.when(
            data: (user) {
              if (user == null) return null;
              if (user.isAdmin) return null;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: isRegisteredAsync.when(
                  data: (isReg) => isReg
                      ? OutlinedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(firestoreServiceProvider)
                                .unregisterFromEvent(user.uid, event.id);
                            ref.invalidate(isRegisteredProvider(event.id));
                          },
                          icon: const Icon(Icons.bookmark_remove),
                          label: const Text('Cancel Registration'),
                        )
                      : FilledButton.icon(
                          onPressed: event.isFull
                              ? null
                              : () async {
                                  final reg = RegistrationModel(
                                    id: '',
                                    userId: user.uid,
                                    eventId: event.id,
                                    userName: user.name,
                                    userEmail: user.email,
                                    userBlock: user.hostelBlock,
                                    registeredAt: DateTime.now(),
                                  );
                                  await ref
                                      .read(firestoreServiceProvider)
                                      .registerForEvent(reg);
                                  ref.invalidate(isRegisteredProvider(event.id));
                                },
                          icon: const Icon(Icons.bookmark_add),
                          label: Text(event.isFull ? 'Event Full' : 'Register Now'),
                        ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),
              );
            },
            loading: () => null,
            error: (_, __) => null,
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
