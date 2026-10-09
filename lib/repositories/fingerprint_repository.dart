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
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FingerprintPending.fromFirestore(doc))
              .toList();
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
  // HITUNG JUMLAH FINGERPRINT AKTIF SANTRI
  // ==========================================

  Future<int> hitungFingerprintSantri(String idSantri) async {
    final snapshot = await _firestore
        .collection('fingerprint-mapping')
        .where('idSantri', isEqualTo: idSantri)
        .where('statusAktif', isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  // ==========================================
  // CEK APAKAH SANTRI MASIH BISA MENDAFTARKAN
  // ==========================================

  Future<bool> bisaDaftarFingerprint(String idSantri) async {
    final jumlah = await hitungFingerprintSantri(idSantri);

    return jumlah < 5;
  }

  // ==========================================
  // NONAKTIFKAN MAPPING LAMA SANTRI
  // ==========================================
  //
  // Digunakan ketika melakukan pendaftaran ulang
  // 5 fingerprint dari awal.
  //
  // Mapping lama tidak langsung dihapus.
  // Statusnya dibuat false agar riwayat tetap ada.
  // ==========================================

  Future<void> nonaktifkanMappingLama(String idSantri) async {
    final snapshot = await _firestore
        .collection('fingerprint-mapping')
        .where('idSantri', isEqualTo: idSantri)
        .where('statusAktif', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'statusAktif': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ==========================================
  // SIMPAN MAPPING FINGERPRINT
  // ==========================================

  Future<void> simpanMapping({
    required String pendingDocumentId,
    required int idSensor,
    required String idFingerprint,
    required String idSantri,
    required String namaSantri,
    required String idLocker,
    required String idPerangkat,
    required String jari,
    required int urutanJari,
  }) async {
    // ========================================
    // 1. CEK DOKUMEN PENDING
    // ========================================

    final pendingRef = _firestore
        .collection('fingerprint-pending')
        .doc(pendingDocumentId);

    final pendingSnapshot = await pendingRef.get();

    if (!pendingSnapshot.exists) {
      throw Exception('Data fingerprint pending tidak ditemukan.');
    }

    final pendingData = pendingSnapshot.data();

    if (pendingData == null) {
      throw Exception('Data fingerprint pending kosong.');
    }

    // ========================================
    // 2. CEK STATUS PENDING
    // ========================================

    if (pendingData['status'] != 'belum_dilabeli') {
      throw Exception('Fingerprint ini sudah diproses sebelumnya.');
    }

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
      'idPerangkat': idPerangkat,
      'jari': jari,
      'urutanJari': urutanJari,
      'statusAktif': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ========================================
    // 4. UPDATE DATA PENDING
    // ========================================

    await pendingRef.update({
      'status': 'sudah_dilabeli',
      'mappedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // SEMUA FINGERPRINT MAPPING AKTIF
  // ==========================================

  Stream<List<Map<String, dynamic>>> watchAllFingerprintMapping() {
    return _firestore
        .collection('fingerprint-mapping')
        .where('statusAktif', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==========================================
  // MULAI ENROLLMENT FINGERPRINT
  // ==========================================
  //
  // Flutter:
  //
  // Pilih Santri + Locker
  //          ↓
  // Daftarkan Finger
  //          ↓
  // Nonaktifkan mapping lama
  //          ↓
  // START_ENROLL
  //          ↓
  // Firestore
  //          ↓
  // ESP32
  //          ↓
  // JM-101B
  //
  // Setiap enrollment selalu dimulai
  // dari 5 jari baru.
  // ==========================================

  Future<String> mulaiEnrollment({
    required String idSantri,
    required String namaSantri,
    required String idLocker,
    required String idPerangkat,
  }) async {
    // ========================================
    // 1. NONAKTIFKAN MAPPING LAMA
    // ========================================
    //
    // Tidak menghapus data lama.
    // Hanya mengubah statusAktif menjadi false.
    //

    await nonaktifkanMappingLama(idSantri);

    // ========================================
    // 2. DOKUMEN COMMAND BERDASARKAN PERANGKAT
    // ========================================

    final commandRef = _firestore
        .collection('enrollment-commands')
        .doc(idPerangkat);

    // ========================================
    // 3. SIMPAN PERINTAH START_ENROLL
    // ========================================

    await commandRef.set({
      'command': 'START_ENROLL',
      'idSantri': idSantri,
      'namaSantri': namaSantri,
      'idLocker': idLocker,
      'idPerangkat': idPerangkat,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return commandRef.id;
  }
}
