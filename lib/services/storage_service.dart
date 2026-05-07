import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadEventBanner(File file) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('event_banners/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
