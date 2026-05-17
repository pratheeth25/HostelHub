import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/attendance_models.dart';
import '../../../../core/models/user_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Streams ───────────────────────────────────────────────────────────────

  Stream<List<EventModel>> get eventsStream {
    return _firestore
        .collection('events')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EventModel.fromMap(d.id, d.data())).toList());
  }

  // ── Student count (excludes admins) ──────────────────────────────────────

  Future<int> getTotalStudentCount() async {
    final snap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .count()
        .get();
    return snap.count ?? 0;
  }

  // ── Create events ─────────────────────────────────────────────────────────

  /// Creates a mandatory Evening Gathering entry for [date].
  Future<String?> createGathering(DateTime date) async {
    try {
      final event = EventModel(
        id: '',
        type: 'gathering',
        title: 'Evening Gathering',
        description: '',
        date: date,
      );
      await _firestore.collection('events').add(event.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Creates a scheduled event with a title, description, date and optional times.
  Future<String?> createEvent({
    required String title,
    required String description,
    required DateTime date,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final event = EventModel(
        id: '',
        type: 'event',
        title: title,
        description: description,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      await _firestore.collection('events').add(event.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Admin: students by year ──────────────────────────────────────────────

  Future<List<UserModel>> getStudentsByYear(String year) async {
    final snap = await _firestore
        .collection('users')
        .where('year', isEqualTo: year)
        .where('role', isEqualTo: 'student')
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  // ── Admin: attendance records for an event ───────────────────────────────

  Future<List<AttendanceRecord>> getMarkedRecordsForEvent(
      String eventId) async {
    final snap = await _firestore
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .get();
    return snap.docs
        .map((d) => AttendanceRecord.fromMap(d.id, d.data()))
        .toList();
  }

  Future<bool> hasMarkedAttendance(String userId, String eventId) async {
    final snap = await _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .get();
    return snap.docs.isNotEmpty;
  }

  // ── Admin: mark / unmark attendance for a student ────────────────────────

  Future<String?> markAttendanceAsAdmin({
    required String userId,
    required String eventId,
    required String userYear,
  }) async {
    try {
      final already = await hasMarkedAttendance(userId, eventId);
      if (already) return null;
      final record = AttendanceRecord(
        id: '',
        userId: userId,
        eventId: eventId,
        sessionType: 'attendance',
        timestamp: DateTime.now(),
        userYear: userYear,
      );
      await _firestore.collection('attendance').add(record.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> unmarkAttendanceAsAdmin(
      String userId, String eventId) async {
    try {
      final snap = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── User: leave ──────────────────────────────────────────────────────────

  Future<bool> hasMarkedLeave(String userId, String eventId) async {
    final snap = await _firestore
        .collection('leaves')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<String?> markLeave({
    required String userId,
    required String eventId,
  }) async {
    try {
      final already = await hasMarkedLeave(userId, eventId);
      if (already) return 'Already marked as on leave';
      final record = LeaveRecord(
        id: '',
        userId: userId,
        eventId: eventId,
        timestamp: DateTime.now(),
      );
      await _firestore.collection('leaves').add(record.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> cancelLeave({
    required String userId,
    required String eventId,
  }) async {
    try {
      final snap = await _firestore
          .collection('leaves')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Report stream ─────────────────────────────────────────────────────────

  Stream<List<AttendanceRecord>> getAttendanceForEvent(String eventId) {
    return _firestore
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AttendanceRecord.fromMap(d.id, d.data()))
            .toList());
  }
}

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<EventModel>> get eventsStream {
    return _firestore
        .collection('events')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EventModel.fromMap(d.id, d.data())).toList());
  }
