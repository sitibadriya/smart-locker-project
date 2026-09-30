import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/santri.dart';

class SantriRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'santri';

  Stream<List<Santri>> getSantriList() {
    return _db.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Santri.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}