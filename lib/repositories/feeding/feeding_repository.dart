import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/feeding/feeding_model.dart';

class FeedingRepository {
  final FirebaseFirestore _firestore;

  FeedingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Feeding>> streamFeedings(String babyId) {
    return _firestore
        .collection('babies')
        .doc(babyId)
        .collection('feedings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Feeding.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addFeeding({
    required String babyId,
    required Feeding feeding,
  }) async {
    await _firestore
        .collection('babies')
        .doc(babyId)
        .collection('feedings')
        .add(feeding.toMap());
  }

  Future<void> deleteFeeding({
    required String babyId,
    required String feedingId,
  }) async {
    await _firestore
        .collection('babies')
        .doc(babyId)
        .collection('feedings')
        .doc(feedingId)
        .delete();
  }
}