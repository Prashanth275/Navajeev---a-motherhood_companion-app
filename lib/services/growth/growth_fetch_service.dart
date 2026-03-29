import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/growth_record_model.dart';

class GrowthFetchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<GrowthRecord>> streamGrowthRecords(String babyId) {
    return _db
        .collection('babies')
        .doc(babyId)
        .collection('growth_records')
        .orderBy('check_in_date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
            GrowthRecord.fromFirestore(doc.id, doc.data()),
      )
          .toList();
    });
  }

  Future<GrowthRecord?> fetchLatest(String babyId) async {
    final snap = await _db
        .collection('babies')
        .doc(babyId)
        .collection('growth_records')
        .orderBy('check_in_date', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;
    return GrowthRecord.fromFirestore(doc.id, doc.data());
  }
}
