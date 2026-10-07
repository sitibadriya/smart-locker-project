import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fingerprint_pending.dart';
import '../models/santri.dart';

class FingerprintRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================
  // FINGERPRINT PENDING
  // ==========================================

  Stream<List<FingerprintPending>> watchPendingFingerprints() {
    return _firestore
        .collection('fingerprint-pending')
        .where('status', isEqualTo: 'belum_dilabeli')
        .snapshots()
        .asyncMap((pendingSnapshot) async {
          // Ambil semua fingerprint yang sudah memiliki mapping aktif
          final mappingSnapshot = await _firestore
              .collection('fingerprint-mapping')
              .where('statusAktif', isEqualTo: true)
              .get();

          // Ubah semua idSensor menjadi String
          // supaya int 1 dan String "1" dianggap sama
          final Set<String> idSensorSudahTerdaftar = {};

          for (final doc in mappingSnapshot.docs) {
            final data = doc.data();

            final idSensor = data['idSensor'];

            if (idSensor != null) {
              idSensorSudahTerdaftar.add(idSensor.toString());
            }
          }

          // Ambil data pending
          final semuaPending = pendingSnapshot.docs
              .map((doc) => FingerprintPending.fromFirestore(doc))
              .toList();

          // Hanya tampilkan ID sensor yang BELUM
          // memiliki mapping aktif
          final pendingBelumTerdaftar = semuaPending
              .where(
                (fingerprint) => !idSensorSudahTerdaftar.contains(
                  fingerprint.idSensor.toString(),
                ),
              )
              .toList();

          return pendingBelumTerdaftar;
        });
  }

  // ==========================================
  // DATA SANTRI AKTIF
  // ==========================================

  Stream<List<Santri>> watchSantriAktif() {
    return _firestore
        .collection('santri')
        .where('statusAktif', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Santri.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // ==========================================
  // DATA FINGERPRINT MILIK SANTRI
  // ==========================================

  Stream<List<Map<String, dynamic>>> watchFingerprintSantri(String idSantri) {
    return _firestore
        .collection('fingerprint-mapping')
        .where('idSantri', isEqualTo: idSantri)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data())
              .where((data) => data['statusAktif'] == true)
              .toList();
        });
  }

  // ==========================================
  // SIMPAN MAPPING FINGERPRINT
  // ==========================================

  Future<void> simpanMapping({
    required String pendingDocumentId,
    required int idSensor,
    required String idSantri,
    required String namaSantri,
    required String idLocker,
  }) async {
    // ========================================
    // 1. CEK JUMLAH FINGERPRINT AKTIF
    // ========================================

    final mappingSnapshot = await _firestore
        .collection('fingerprint-mapping')
        .where('idSantri', isEqualTo: idSantri)
        .where('statusAktif', isEqualTo: true)
        .get();

    final jumlahFingerprint = mappingSnapshot.docs.length;

    // Maksimal 5 fingerprint per santri
    if (jumlahFingerprint >= 5) {
      throw Exception(
        'Santri ini sudah memiliki '
        'maksimal 5 fingerprint aktif.',
      );
    }

    // ========================================
    // 2. BUAT ID FINGERPRINT APLIKASI
    // ========================================

    final String idFingerprint = 'FP${idSensor.toString().padLeft(2, '0')}';

    // ========================================
    // 3. SIMPAN KE fingerprint-mapping
    // ========================================

    final mappingRef = _firestore
        .collection('fingerprint-mapping')
        .doc(idFingerprint);

    await mappingRef.set({
      'idFingerprint': idFingerprint,
      'idSensor': idSensor,
      'idSantri': idSantri,
      'namaSantri': namaSantri,
      'idLocker': idLocker,
      'statusAktif': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ========================================
    // 4. UPDATE DATA PENDING
    // ========================================

    await _firestore
        .collection('fingerprint-pending')
        .doc(pendingDocumentId)
        .update({
          'status': 'sudah_dilabeli',
          'mappedAt': FieldValue.serverTimestamp(),
          'idSantri': idSantri,
          'namaSantri': namaSantri,
        });
  }
}
