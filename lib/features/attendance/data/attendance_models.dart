import 'package:cloud_firestore/cloud_firestore.dart';

/// type == 'gathering'  → Evening Gathering (mandatory daily roll-call)
/// type == 'event'      → Scheduled Event (admin-created, date/time specific)
class EventModel {
  final String id;
  final String type; // 'gathering' | 'event'
  final String title;
  final String description;
  final DateTime date;
  final String? startTime; // "HH:mm" format
  final String? endTime;   // "HH:mm" format

  EventModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
  });

  bool get isGathering => type == 'gathering';
  bool get isEvent => type == 'event';

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      type: map['type'] ?? 'event',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}

class AttendanceRecord {
  final String id;
  final String userId;
  final String eventId;
  final String sessionType; // 'morning' | 'evening'
  final DateTime timestamp;
  final String userYear;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.sessionType,
    required this.timestamp,
    required this.userYear,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      id: id,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      sessionType: map['sessionType'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userYear: map['userYear'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'sessionType': sessionType,
      'timestamp': Timestamp.fromDate(timestamp),
      'userYear': userYear,
    };
  }
}

class LeaveRecord {
  final String id;
  final String userId;
  final String eventId;
  final DateTime timestamp;

  LeaveRecord({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.timestamp,
  });

  factory LeaveRecord.fromMap(String id, Map<String, dynamic> map) {
    return LeaveRecord(
      id: id,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
