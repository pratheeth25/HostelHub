import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../../models/event_model.dart';
import '../../auth/providers/auth_provider.dart';

final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getUpcomingEvents();
});

final allEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getAllEvents();
});

final userRegisteredEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getUserRegisteredEvents(user.uid);
});

final isRegisteredProvider = FutureProvider.family<bool, String>((ref, eventId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return false;
  return ref.watch(firestoreServiceProvider).isRegistered(user.uid, eventId);
});
