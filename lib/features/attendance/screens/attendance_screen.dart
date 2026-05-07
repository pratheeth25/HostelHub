import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../../models/attendance_model.dart';
import '../../../models/registration_model.dart';
import '../../auth/providers/auth_provider.dart';

final _registrationsProvider =
    StreamProvider.family<List<RegistrationModel>, String>((ref, eventId) {
  return ref.watch(firestoreServiceProvider).getEventRegistrations(eventId);
});

final _attendanceProvider =
    StreamProvider.family<List<AttendanceModel>, String>((ref, eventId) {
  return ref.watch(firestoreServiceProvider).getEventAttendance(eventId);
});

class AttendanceScreen extends ConsumerWidget {
  final String eventId;
  const AttendanceScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regsAsync = ref.watch(_registrationsProvider(eventId));
    final attendanceAsync = ref.watch(_attendanceProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          regsAsync.when(
            data: (regs) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('${regs.length} Registered')),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: regsAsync.when(
        data: (registrations) {
          if (registrations.isEmpty) {
            return const Center(child: Text('No registrations yet'));
          }
          return attendanceAsync.when(
            data: (attendanceList) {
              final attendanceMap = {
                for (final a in attendanceList) a.userId: a
              };
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: registrations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final reg = registrations[i];
                  final att = attendanceMap[reg.userId];
                  final isPresent = att?.isPresent ?? false;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(reg.userName.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(reg.userName),
                    subtitle: Text(reg.userEmail),
                    trailing: Switch(
                      value: isPresent,
                      onChanged: (val) async {
                        await ref
                            .read(firestoreServiceProvider)
                            .markAttendance(AttendanceModel(
                              id: att?.id ?? '',
                              userId: reg.userId,
                              eventId: eventId,
                              userName: reg.userName,
                              isPresent: val,
                              markedAt: DateTime.now(),
                            ));
                      },
                    ),
                    tileColor: isPresent
                        ? Colors.green.withOpacity(0.08)
                        : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
