import 'package:cloud_firestore/cloud_firestore.dart';

class MealModel {
  final String id;
  final String userId;
  final int breakfast;
  final int lunch;
  final int dinner;
  final DateTime date;

  MealModel({
    required this.id,
    required this.userId,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.date,
  });

  factory MealModel.fromMap(String id, Map<String, dynamic> map) {
    return MealModel(
      id: id,
      userId: map['userId'] ?? '',
      breakfast: map['breakfast'] ?? 0,
      lunch: map['lunch'] ?? 0,
      dinner: map['dinner'] ?? 0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'date': Timestamp.fromDate(date),
    };
  }
}
