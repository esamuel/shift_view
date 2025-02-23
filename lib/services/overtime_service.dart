import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/overtime_rule.dart';
import 'firebase_service.dart';

class OvertimeService {
  static final OvertimeService _instance = OvertimeService._internal();

  factory OvertimeService() {
    return _instance;
  }

  OvertimeService._internal();

  Stream<List<OvertimeRule>> getOvertimeRules() {
    final userId = FirebaseService.auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('overtime_rules')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OvertimeRule.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addOvertimeRule(OvertimeRule rule) async {
    final userId = FirebaseService.auth.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('overtime_rules')
        .add(rule.toJson());
  }

  Future<void> updateOvertimeRule(OvertimeRule rule) async {
    final userId = FirebaseService.auth.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('overtime_rules')
        .doc(rule.id)
        .update(rule.toJson());
  }

  Future<void> deleteOvertimeRule(String ruleId) async {
    final userId = FirebaseService.auth.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('overtime_rules')
        .doc(ruleId)
        .delete();
  }

  List<OvertimeRule> getDefaultRules() {
    return [
      // Special day rules
      OvertimeRule(
        id: FirebaseFirestore.instance.collection('overtime_rules').doc().id,
        hoursThreshold: 8.0,
        rate: 1.75,
        isForSpecialDays: true,
        appliesOnWeekends: true,
      ),
      OvertimeRule(
        id: FirebaseFirestore.instance.collection('overtime_rules').doc().id,
        hoursThreshold: 10.0,
        rate: 2.0,
        isForSpecialDays: true,
        appliesOnWeekends: true,
      ),
      // Regular workday rules
      OvertimeRule(
        id: FirebaseFirestore.instance.collection('overtime_rules').doc().id,
        hoursThreshold: 8.0,
        rate: 1.25,
        isForSpecialDays: false,
        appliesOnWeekends: false,
      ),
      OvertimeRule(
        id: FirebaseFirestore.instance.collection('overtime_rules').doc().id,
        hoursThreshold: 10.0,
        rate: 1.5,
        isForSpecialDays: false,
        appliesOnWeekends: false,
      ),
    ];
  }

  Future<void> initializeDefaultRules() async {
    final userId = FirebaseService.auth.currentUser?.uid;
    if (userId == null) return;

    final rulesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('overtime_rules');

    final existingRules = await rulesCollection.get();
    if (existingRules.docs.isEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (final rule in getDefaultRules()) {
        final doc = rulesCollection.doc();
        batch.set(doc, rule.toJson());
      }
      await batch.commit();
    }
  }
}
