import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final String eventId;
  final String userName;
  final bool isPresent;
  final DateTime markedAt;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.userName,
    required this.isPresent,
    required this.markedAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String docId) {
    return AttendanceModel(
      id: docId,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      userName: map['userName'] ?? '',
      isPresent: map['isPresent'] ?? false,
      markedAt: (map['markedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'userName': userName,
      'isPresent': isPresent,
      'markedAt': Timestamp.fromDate(markedAt),
    };
  }
}
