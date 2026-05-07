import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String course,
    required int year,
    required String hostelBlock,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final role = year == 3 ? 'admin' : 'student';
    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      course: course,
      year: year,
      hostelBlock: hostelBlock,
      role: role,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'name': user.name,
      'course': user.course,
      'hostelBlock': user.hostelBlock,
    });
  }
}
