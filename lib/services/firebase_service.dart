import 'package:flutter/foundation.dart';
import 'dart:js_util' as js_util;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/overtime_rule.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Get current user's email
  static String? get currentUserEmail => auth.currentUser?.email;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDadgwtZgZfAy2BkjPrgHpzvYbPQFUOb8o",
        authDomain: "new-shift-view.firebaseapp.com",
        projectId: "new-shift-view",
        storageBucket: "new-shift-view.appspot.com",
        messagingSenderId: "110845479034",
        appId: "1:110845479034:web:52729f4ea8caf4d33513c3",
      ),
    );

    // Initialize user structure if needed
    await initializeUserStructure();
  }

  static Future<void> initializeUserStructure() async {
    if (currentUserEmail == null) return;

    try {
      print('Initializing structure for user: ${currentUserEmail}');

      // Get user document reference
      final userDoc = _firestore.collection('users').doc(currentUserEmail);

      // Create or update user document with email
      await userDoc.set({
        'email': currentUserEmail,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Create settings subcollection
      final settingsDoc = userDoc.collection('settings').doc('general');
      final settingsSnapshot = await settingsDoc.get();

      // If settings don't exist, create them with defaults
      if (!settingsSnapshot.exists) {
        print('Creating default settings for user');
        await settingsDoc.set({
          'hourlyWage': 40.0,
          'taxDeduction': 10.0,
          'startOnSunday': true,
          'languageCode': 'en',
          'countryCode': 'IL',
          'baseHoursWeekday': 8.0,
          'baseHoursSpecialDay': 8.0,
          'isDarkMode': false,
        });
      }

      // Remove the default rule initialization
      // print('Updating overtime rules for user');
      // final rulesCollection = userDoc.collection('overtime_rules');

      // Delete existing rules
      // final existingRules = await rulesCollection.get();
      // final batch = _firestore.batch();
      // for (var doc in existingRules.docs) {
      //   batch.delete(doc.reference);
      // }
      // await batch.commit();

      // Add new rules
      // final newRules = [
      //   {
      //     'hoursThreshold': 8.0,
      //     'rate': 1.5,
      //     'isForSpecialDays': true,
      //     'appliesOnWeekends': true,
      //     'appliesOnFestiveDays': false,
      //     'createdAt': FieldValue.serverTimestamp(),
      //   },
      //   {
      //     'hoursThreshold': 10.0,
      //     'rate': 1.75,
      //     'isForSpecialDays': true,
      //     'appliesOnWeekends': true,
      //     'appliesOnFestiveDays': false,
      //     'createdAt': FieldValue.serverTimestamp(),
      //   },
      //   {
      //     'hoursThreshold': 8.0,
      //     'rate': 1.25,
      //     'isForSpecialDays': false,
      //     'appliesOnWeekends': false,
      //     'appliesOnFestiveDays': false,
      //     'createdAt': FieldValue.serverTimestamp(),
      //   },
      //   {
      //     'hoursThreshold': 10.0,
      //     'rate': 1.5,
      //     'isForSpecialDays': false,
      //     'appliesOnWeekends': false,
      //     'appliesOnFestiveDays': false,
      //     'createdAt': FieldValue.serverTimestamp(),
      //   }
      // ];

      // Use batch write for atomic operation
      // final newBatch = _firestore.batch();
      // for (var rule in newRules) {
      //   final doc = rulesCollection.doc();
      //   newBatch.set(doc, rule);
      // }
      // await newBatch.commit();
      // print('Overtime rules updated successfully');
    } catch (e) {
      print('Error initializing user structure: $e');
      rethrow;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('profile');
        googleProvider.addScope('email');
        final promise = auth.signInWithPopup(googleProvider);
        return js_util.promiseToFuture(promise);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await auth.signInWithCredential(credential);
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Firestore methods for user settings
  static Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    if (currentUserEmail == null) {
      print('saveUserSettings: No user email available');
      return;
    }

    print('saveUserSettings: Saving settings for user ${currentUserEmail}');
    try {
      await _firestore
          .collection('users')
          .doc(currentUserEmail)
          .collection('settings')
          .doc('general')
          .set(settings, SetOptions(merge: true));
      print('saveUserSettings: Settings saved successfully');
    } catch (e) {
      print('saveUserSettings: Error saving settings: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserSettings() async {
    if (currentUserEmail == null) {
      print('getUserSettings: No user email available');
      return null;
    }

    print('getUserSettings: Fetching settings for user ${currentUserEmail}');
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserEmail)
          .collection('settings')
          .doc('general')
          .get();

      if (doc.exists) {
        print('getUserSettings: Settings found');
        return doc.data();
      } else {
        print('getUserSettings: No settings found');
        return null;
      }
    } catch (e) {
      print('getUserSettings: Error fetching settings: $e');
      rethrow;
    }
  }

  // Firestore methods for shifts
  static Stream<List<Shift>> getShifts() {
    if (currentUserEmail == null) {
      print('getShifts: No user email available');
      return Stream.value([]);
    }

    print('getShifts: Fetching shifts for user ${currentUserEmail}');
    return _firestore
        .collection('users')
        .doc(currentUserEmail)
        .collection('shifts')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      print('getShifts: Received ${snapshot.docs.length} shifts');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print('getShifts: Processing shift ${doc.id}');
        return Shift.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  static Future<void> saveShift(Shift shift) async {
    if (currentUserEmail == null) {
      print('saveShift: No user email available');
      return;
    }

    print('saveShift: Saving shift for user ${currentUserEmail}');
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(currentUserEmail)
          .collection('shifts')
          .add(shift.toJson());
      print('saveShift: Successfully saved shift with ID ${docRef.id}');
    } catch (e) {
      print('saveShift: Error saving shift: $e');
      rethrow;
    }
  }

  static Future<void> updateShift(String shiftId, Shift shift) async {
    if (currentUserEmail == null) return;

    await _firestore
        .collection('users')
        .doc(currentUserEmail)
        .collection('shifts')
        .doc(shiftId)
        .update(shift.toJson());
  }

  static Future<void> deleteShift(String shiftId) async {
    if (currentUserEmail == null) return;

    await _firestore
        .collection('users')
        .doc(currentUserEmail)
        .collection('shifts')
        .doc(shiftId)
        .delete();
  }

  static Future<void> saveOvertimeRules(List<OvertimeRule> rules) async {
    if (currentUserEmail == null) {
      print('saveOvertimeRules: No user email available');
      throw Exception('User not logged in');
    }

    print(
        'saveOvertimeRules: Saving ${rules.length} rules for user ${currentUserEmail}');
    try {
      // Get the user document reference
      final userDoc = _firestore.collection('users').doc(currentUserEmail);

      // Get reference to overtime_rules collection
      final rulesCollection = userDoc.collection('overtime_rules');

      // First, get all existing rules
      final existingRules = await rulesCollection.get();

      // Create a batch for atomic operations
      final batch = _firestore.batch();

      // Create a set of unique rule combinations to prevent duplicates
      final Set<String> uniqueRules = {};

      // Delete all existing rules
      for (var doc in existingRules.docs) {
        batch.delete(doc.reference);
      }

      // Add new rules, preventing duplicates based on properties
      for (var rule in rules) {
        // Create a unique key for the rule based on its properties
        final ruleKey =
            '${rule.hoursThreshold}-${rule.rate}-${rule.isForSpecialDays}-${rule.appliesOnWeekends}-${rule.appliesOnFestiveDays}';

        // Only add if this combination doesn't exist
        if (!uniqueRules.contains(ruleKey)) {
          uniqueRules.add(ruleKey);

          final newDoc = rulesCollection.doc();
          final ruleData = {
            'hoursThreshold': rule.hoursThreshold,
            'rate': rule.rate,
            'isForSpecialDays': rule.isForSpecialDays,
            'appliesOnWeekends': rule.appliesOnWeekends,
            'appliesOnFestiveDays': rule.appliesOnFestiveDays,
            'createdAt': FieldValue.serverTimestamp(),
          };
          batch.set(newDoc, ruleData);
        }
      }

      // Commit all changes atomically
      await batch.commit();
      print(
          'saveOvertimeRules: Successfully committed changes. Added ${uniqueRules.length} unique rules.');
    } catch (e) {
      print('saveOvertimeRules: Error saving rules: $e');
      rethrow;
    }
  }

  static Stream<List<OvertimeRule>> getOvertimeRules() {
    if (currentUserEmail == null) {
      print('getOvertimeRules: No user email available');
      return Stream.value([]);
    }

    final rulesRef = _firestore
        .collection('users')
        .doc(currentUserEmail)
        .collection('overtime_rules');

    return rulesRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      final rules = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OvertimeRule.fromJson(data);
      }).toList();

      return rules;
    });
  }

  // Add a method to verify rules exist
  static Future<void> verifyOvertimeRules() async {
    if (currentUserEmail == null) {
      print('verifyOvertimeRules: No user email available');
      return;
    }

    try {
      final rulesRef = _firestore
          .collection('users')
          .doc(currentUserEmail)
          .collection('overtime_rules');

      print('verifyOvertimeRules: Checking path: ${rulesRef.path}');

      final rules = await rulesRef.get();
      print('verifyOvertimeRules: Found ${rules.docs.length} rules');

      for (var doc in rules.docs) {
        print('verifyOvertimeRules: Rule ${doc.id} data: ${doc.data()}');
      }
    } catch (e) {
      print('verifyOvertimeRules: Error checking rules: $e');
    }
  }

  static Future<void> printOvertimeRules() async {
    if (currentUserEmail == null) {
      print('No user email available');
      return;
    }

    try {
      final rulesRef = _firestore
          .collection('users')
          .doc(currentUserEmail)
          .collection('overtime_rules');

      final rules = await rulesRef.get();
      print('Overtime rules for user ${currentUserEmail}:');
      for (var doc in rules.docs) {
        print('Rule: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching overtime rules: $e');
    }
  }

  static Future<User?> getCurrentUser() async {
    if (kIsWeb) {
      return auth.currentUser;
    } else {
      // Add the else condition here
      // For example:
      // return await auth.currentUser;
      // or
      // return null;
      // This will depend on your specific use case
    }
  }
}
