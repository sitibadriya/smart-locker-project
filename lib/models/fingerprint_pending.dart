import 'package:cloud_firestore/cloud_firestore.dart';

class FingerprintPending {
  final String documentId;
  final String idFingerprint;
  final int idSensor;
  final int urutanJari;
  final String jari;
  final String idPerangkat;
  final String idLocker;
  final String idSantri;
  final String namaSantri;
  final String status;
  final Timestamp? createdAt;

  FingerprintPending({
    required this.documentId,
    required this.idFingerprint,
    required this.idSensor,
    required this.urutanJari,
    required this.jari,
    required this.idPerangkat,
    required this.idLocker,
    required this.idSantri,
    required this.namaSantri,
    required this.status,
    this.createdAt,
  });

  factory FingerprintPending.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return FingerprintPending(
      documentId: document.id,
      idFingerprint: data['idFingerprint']?.toString() ?? '',
      idSensor: (data['idSensor'] as num?)?.toInt() ?? 0,
      urutanJari: (data['urutanJari'] as num?)?.toInt() ?? 0,
      jari: data['jari']?.toString() ?? '',
      idPerangkat: data['idPerangkat']?.toString() ?? '',
      idLocker: data['idLocker']?.toString() ?? '',
      idSantri: data['idSantri']?.toString() ?? '',
      namaSantri: data['namaSantri']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
