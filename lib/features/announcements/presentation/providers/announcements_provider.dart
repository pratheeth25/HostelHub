import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/announcement_model.dart';

class AnnouncementsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AnnouncementModel>> get announcementsStream {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AnnouncementModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<String?> createAnnouncement({
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    try {
      final doc = AnnouncementModel(
        id: '',
        title: title,
        description: description,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('announcements').add(doc.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
