import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/sleep/sleep_session.dart';
import '../../services/auth_service.dart';

class SleepRepository {
  final FirebaseFirestore firestore;
  final AuthService auth;
  final bool isMother;

  SleepRepository({
    required this.firestore,
    required this.auth,
    required this.isMother,
  });

  Future<CollectionReference> _getCollection() async {
    final uid = auth.currentUser!.id;

    if (isMother) {
      return firestore
          .collection('users')
          .doc(uid)
          .collection('mother_sleep');
    } else {
      final babyId = await auth.getActiveBabyId();

      if (babyId == null) {
        throw Exception("No active baby selected");
      }

      return firestore
          .collection('babies')
          .doc(babyId)
          .collection('baby_sleep');
    }
  }

  Stream<List<SleepSession>> streamSessions() async* {
    final collection = await _getCollection();

    yield* collection
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => SleepSession.fromDoc(doc)).toList());
  }

  Future<void> addSession(SleepSession session) async {
    final collection = await _getCollection();
    await collection.add(session.toMap());
  }
}