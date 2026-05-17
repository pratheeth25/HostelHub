import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> loadCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      _currentUser = UserModel.fromMap(doc.data()!);
      notifyListeners();
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String course,
    required String year,
    required String branch,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: 'student',
        course: course,
        year: year,
        branch: branch,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      _currentUser = user;
      return null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadCurrentUser();
      return null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
