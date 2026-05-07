import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String course;
  final int year;
  final String hostelBlock;
  final String role;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.course,
    required this.year,
    required this.hostelBlock,
    required this.role,
    this.fcmToken,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      course: map['course'] ?? '',
      year: map['year'] ?? 1,
      hostelBlock: map['hostelBlock'] ?? '',
      role: map['role'] ?? 'student',
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'course': course,
      'year': year,
      'hostelBlock': hostelBlock,
      'role': role,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? course,
    int? year,
    String? hostelBlock,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      course: course ?? this.course,
      year: year ?? this.year,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      role: role,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
