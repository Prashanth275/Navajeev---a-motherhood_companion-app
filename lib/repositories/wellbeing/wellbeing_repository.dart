import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/wellbeing/wellbeing_model.dart';

class WellbeingRepository {
  final FirebaseFirestore firestore;

  WellbeingRepository(this.firestore);

  CollectionReference _ref(String uid) =>
      firestore
          .collection('users')
          .doc(uid)
          .collection('wellbeing_entries');

  Stream<List<WellbeingEntry>> streamEntries(String uid) {
    return _ref(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => WellbeingEntry.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    ))
        .toList());
  }

  Future<WellbeingEntry?> getEntry(
      String uid,
      String dateId,
      ) async {
    final doc = await _ref(uid).doc(dateId).get();
    if (!doc.exists) return null;

    return WellbeingEntry.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  Future<void> upsertEntry(
      String uid,
      WellbeingEntry entry,
      ) async {
    await _ref(uid)
        .doc(entry.id)
        .set(entry.toMap(), SetOptions(merge: true));
  }
}