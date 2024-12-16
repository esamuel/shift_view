import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/shift.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal();
  
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: kIsWeb ? FirebaseOptions(
          apiKey: "AIzaSyA7oLzBL-AR1N2Y1b7cqhUmFuJMnCqIZkc",
          authDomain: "shift-view-app.firebaseapp.com",
          projectId: "shift-view-app",
          storageBucket: "shift-view-app.appspot.com",
          messagingSenderId: "530556523067",
          appId: "1:530556523067:web:5aad7c47cca98b3f53c21e"
        ) : null,
      );
      print('Firebase initialized successfully in Flutter');
    } catch (e) {
      print('Error initializing Firebase in Flutter: $e');
      rethrow;
    }
  }

  // Get current user ID
  String? get currentUserId => auth.currentUser?.uid;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }

  // Save shift to Firestore
  Future<void> saveShift(Shift shift) async {
    if (currentUserId == null) return;

    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('shifts')
        .doc(shift.id)
        .set(shift.toJson());
  }

  // Get all shifts for current user
  Stream<List<Shift>> getShifts() {
    if (currentUserId == null) return Stream.value([]);

    return firestore
        .collection('users')
        .doc(currentUserId)
        .collection('shifts')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Shift.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Update shift
  Future<void> updateShift(String shiftId, Shift shift) async {
    if (currentUserId == null) return;

    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('shifts')
        .doc(shiftId)
        .update(shift.toJson());
  }

  // Delete shift
  Future<void> deleteShift(String shiftId) async {
    if (currentUserId == null) return;

    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('shifts')
        .doc(shiftId)
        .delete();
  }

  // Save user settings
  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    if (currentUserId == null) return;

    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('settings')
        .doc('user_settings')
        .set(settings);
  }

  // Get user settings
  Future<Map<String, dynamic>?> getUserSettings() async {
    if (currentUserId == null) return null;

    final doc = await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('settings')
        .doc('user_settings')
        .get();

    return doc.data();
  }
} 