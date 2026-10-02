import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/locker_activity.dart';

class LockerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'aktivitas-locker';

  Stream<List<LockerActivity>> getLockerActivities() {
    return _db
        .collection(_collection)
        .orderBy('waktuAkses', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LockerActivity.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
