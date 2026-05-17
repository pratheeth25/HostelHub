import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/complaint_model.dart';

class ComplaintsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> categories = [
    'Hostel',
    'Food',
    'Maintenance',
    'Internet/WiFi',
    'Others',
  ];

  static const List<String> statuses = ['Pending', 'In Progress', 'Resolved'];

  Stream<List<ComplaintModel>> getAllComplaintsStream() {
    return _firestore
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ComplaintModel.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<List<ComplaintModel>> getUserComplaintsStream(String userId) {
    return _firestore
        .collection('complaints')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => ComplaintModel.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<String?> submitComplaint({
    required String title,
    required String description,
    required String category,
    required bool anonymous,
    required String userId,
  }) async {
    try {
      final complaint = ComplaintModel(
        id: '',
        title: title,
        description: description,
        anonymous: anonymous,
        category: category,
        status: 'Pending',
        userId: anonymous ? 'anonymous' : userId,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('complaints').add(complaint.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateStatus(String id, String status) async {
    try {
      await _firestore.collection('complaints').doc(id).update({'status': status});
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
