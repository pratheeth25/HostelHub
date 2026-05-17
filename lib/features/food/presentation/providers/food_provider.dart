import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/meal_model.dart';

class FoodProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<MealModel?> getUserMealForDate(String userId, DateTime date) async {
    final key = _dateKey(date);
    final snap = await _firestore
        .collection('meals')
        .where('userId', isEqualTo: userId)
        .where('dateKey', isEqualTo: key)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return MealModel.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  Future<String?> updateMeal({
    required String userId,
    required DateTime date,
    required int breakfast,
    required int lunch,
    required int dinner,
  }) async {
    try {
      final key = _dateKey(date);
      final snap = await _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .where('dateKey', isEqualTo: key)
          .limit(1)
          .get();
      final data = {
        'userId': userId,
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'date': Timestamp.fromDate(date),
        'dateKey': key,
      };
      if (snap.docs.isEmpty) {
        await _firestore.collection('meals').add(data);
      } else {
        await _firestore.collection('meals').doc(snap.docs.first.id).update(data);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<Map<String, int>> getDailyTotalsStream(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _firestore
        .collection('meals')
        .where('dateKey', isEqualTo: key)
        .snapshots()
        .map((snap) {
      int breakfast = 0, lunch = 0, dinner = 0;
      for (final doc in snap.docs) {
        breakfast += (doc.data()['breakfast'] as num?)?.toInt() ?? 0;
        lunch += (doc.data()['lunch'] as num?)?.toInt() ?? 0;
        dinner += (doc.data()['dinner'] as num?)?.toInt() ?? 0;
      }
      return {'breakfast': breakfast, 'lunch': lunch, 'dinner': dinner};
    });
  }
}
