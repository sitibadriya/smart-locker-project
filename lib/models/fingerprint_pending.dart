import 'package:cloud_firestore/cloud_firestore.dart';

class FingerprintPending {
  final String documentId;
  final int idSensor;
  final String idPerangkat;
  final String idLocker;
  final String status;
  final Timestamp? createdAt;

  FingerprintPending({
    required this.documentId,
    required this.idSensor,
    required this.idPerangkat,
    required this.idLocker,
    required this.status,
    this.createdAt,
  });

  factory FingerprintPending.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return FingerprintPending(
      documentId: document.id,
      idSensor: data['idSensor'] ?? 0,
      idPerangkat: data['idPerangkat'] ?? '',
      idLocker: data['idLocker'] ?? '',
      status: data['status'] ?? '',
      createdAt: data['createdAt'],
    );
  }
}
