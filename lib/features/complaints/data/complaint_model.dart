import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final bool anonymous;
  final String category;
  final String status;
  final String userId;
  final DateTime createdAt;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.anonymous,
    required this.category,
    required this.status,
    required this.userId,
    required this.createdAt,
  });

  factory ComplaintModel.fromMap(String id, Map<String, dynamic> map) {
    return ComplaintModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      anonymous: map['anonymous'] ?? false,
      category: map['category'] ?? '',
      status: map['status'] ?? 'Pending',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'anonymous': anonymous,
      'category': category,
      'status': status,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
