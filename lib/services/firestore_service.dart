import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../models/attendance_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<EventModel>> getUpcomingEvents() {
    return _db
        .collection('events')
        .where('isActive', isEqualTo: true)
        .where('dateTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('dateTime')
        .snapshots()
        .map((snap) => snap.docs.map((d) => EventModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<EventModel>> getAllEvents() {
    return _db
        .collection('events')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => EventModel.fromMap(d.data(), d.id)).toList());
  }

  Future<EventModel> createEvent(EventModel event) async {
    final ref = await _db.collection('events').add(event.toMap());
    return event.copyWith();
  }

  Future<void> updateEvent(EventModel event) async {
    await _db.collection('events').doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  Future<bool> isRegistered(String userId, String eventId) async {
    final query = await _db
        .collection('registrations')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> registerForEvent(RegistrationModel registration) async {
    final batch = _db.batch();
    final regRef = _db.collection('registrations').doc();
    batch.set(regRef, registration.toMap());
    final eventRef = _db.collection('events').doc(registration.eventId);
    batch.update(eventRef, {'registeredCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> unregisterFromEvent(String userId, String eventId) async {
    final query = await _db
        .collection('registrations')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final batch = _db.batch();
      batch.delete(query.docs.first.reference);
      final eventRef = _db.collection('events').doc(eventId);
      batch.update(eventRef, {'registeredCount': FieldValue.increment(-1)});
      await batch.commit();
    }
  }

  Stream<List<RegistrationModel>> getEventRegistrations(String eventId) {
    return _db
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => RegistrationModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<EventModel>> getUserRegisteredEvents(String userId) {
    return _db
        .collection('registrations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snap) async {
      final eventIds = snap.docs.map((d) => d.data()['eventId'] as String).toList();
      if (eventIds.isEmpty) return [];
      final events = await Future.wait(
        eventIds.map((id) => _db.collection('events').doc(id).get()),
      );
      return events
          .where((d) => d.exists)
          .map((d) => EventModel.fromMap(d.data()!, d.id))
          .toList();
    });
  }

  Future<void> markAttendance(AttendanceModel attendance) async {
    final query = await _db
        .collection('attendance')
        .where('userId', isEqualTo: attendance.userId)
        .where('eventId', isEqualTo: attendance.eventId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'isPresent': attendance.isPresent});
    } else {
      await _db.collection('attendance').add(attendance.toMap());
    }
  }

  Stream<List<AttendanceModel>> getEventAttendance(String eventId) {
    return _db
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AttendanceModel.fromMap(d.data(), d.id)).toList());
  }

  Future<AttendanceModel?> getUserAttendance(String userId, String eventId) async {
    final query = await _db
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return AttendanceModel.fromMap(query.docs.first.data(), query.docs.first.id);
  }

  Stream<List<NotificationModel>> getNotifications() {
    return _db
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NotificationModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _db.collection('notifications').add(notification.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUserFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }
}
