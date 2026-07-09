import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileProvider with ChangeNotifier {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? babyData;
  List<Map<String, dynamic>> parents = [];

  bool isLoading = true;

  Future<void> fetchUserData(String uid) async {
    try {
      isLoading = true;
      notifyListeners();

      // FETCH USER
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        userData = null;
        isLoading = false;
        notifyListeners();
        return;
      }

      userData = userDoc.data();

      // RESET
      babyData = null;
      parents = [];

      final stage = userData?['stage'];

      // IF POSTPARTUM → FETCH BABY + PARENTS
      if (stage == 'postpartum' &&
          userData?['active_baby_id'] != null) {

        final babyDoc = await FirebaseFirestore.instance
            .collection('babies')
            .doc(userData!['active_baby_id'])
            .get();

        if (babyDoc.exists) {
          babyData = babyDoc.data();

          // FETCH ALL PARENTS
          final parentUids = babyData?['parent_uids'] ?? [];

          for (String parentUid in parentUids) {
            final parentDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(parentUid)
                .get();

            if (parentDoc.exists) {
              parents.add(parentDoc.data()!);
            }
          }
        }
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("ProfileProvider Error: $e");
      isLoading = false;
      notifyListeners();
    }
  }
}