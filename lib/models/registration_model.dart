import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationModel {
  final String id;
  final String userId;
  final String eventId;
  final String userName;
  final String userEmail;
  final String userBlock;
  final DateTime registeredAt;

  RegistrationModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.userName,
    required this.userEmail,
    required this.userBlock,
    required this.registeredAt,
  });

  factory RegistrationModel.fromMap(Map<String, dynamic> map, String docId) {
    return RegistrationModel(
      id: docId,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userBlock: map['userBlock'] ?? '',
      registeredAt: (map['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'userName': userName,
      'userEmail': userEmail,
      'userBlock': userBlock,
      'registeredAt': Timestamp.fromDate(registeredAt),
    };
  }
}
