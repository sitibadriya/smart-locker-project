import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/santri.dart';

class FingerprintRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================
  // DATA SANTRI AKTIF
  // ==========================================

  Stream<List<Santri>> watchSantriAktif() {
    return _firestore
        .collection('santri')
        .where('statusAktif', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Santri.fromFirestore(doc.data()))
              .toList();
        });
  }

  // ==========================================
  // STATISTIK AKTIVITAS LOCKER
  // ==========================================

  // Mengambil aktivitas terbaru dari Firestore.
  Future<List<Map<String, dynamic>>> _ambilAktivitasTerakhir(int jumlah) async {
    final snapshot = await _firestore
        .collection('locker-activity')
        .orderBy('waktu', descending: true)
        .limit(jumlah)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Mengambil aktivitas pada tanggal tertentu.
  Future<List<Map<String, dynamic>>> _ambilAktivitasTanggal(
    DateTime tanggal,
  ) async {
    final awalHari = DateTime(tanggal.year, tanggal.month, tanggal.day);

    final awalBesok = awalHari.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('locker-activity')
        .where('waktu', isGreaterThanOrEqualTo: Timestamp.fromDate(awalHari))
        .where('waktu', isLessThan: Timestamp.fromDate(awalBesok))
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // POIN 1:
  // Rata-rata jeda waktu antar aktivitas terbaru,
  // maksimal 10 aktivitas. Hasil dalam menit.
  Future<double?> hitungRataRataJeda10Aktivitas() async {
    final aktivitas = await _ambilAktivitasTerakhir(10);

    final waktu = aktivitas
        .map((item) => item['waktu'])
        .whereType<Timestamp>()
        .map((timestamp) => timestamp.toDate())
        .toList();

    if (waktu.length < 2) {
      return null;
    }

    double totalMenit = 0;

    for (int i = 0; i < waktu.length - 1; i++) {
      final selisihDetik = waktu[i].difference(waktu[i + 1]).inSeconds.abs();

      totalMenit += selisihDetik / 60.0;
    }

    return totalMenit / (waktu.length - 1);
  }

  // POIN 2:
  // Jumlah aktivitas pada tanggal tertentu.
  Future<int> hitungJumlahAktivitasTanggal(DateTime tanggal) async {
    final aktivitas = await _ambilAktivitasTanggal(tanggal);

    return aktivitas.length;
  }

  // POIN 3:
  // Persentase akses berhasil pada tanggal tertentu.
  Future<double?> hitungPersentaseBerhasil(DateTime tanggal) async {
    final aktivitas = await _ambilAktivitasTanggal(tanggal);

    if (aktivitas.isEmpty) {
      return null;
    }

    final jumlahBerhasil = aktivitas.where((item) {
      return item['hasilAkses'] == 'DIIZINKAN';
    }).length;

    return (jumlahBerhasil / aktivitas.length) * 100;
  }

  // POIN 4:
  // Persentase akses gagal pada tanggal tertentu.
  Future<double?> hitungPersentaseGagal(DateTime tanggal) async {
    final aktivitas = await _ambilAktivitasTanggal(tanggal);

    if (aktivitas.isEmpty) {
      return null;
    }

    final jumlahGagal = aktivitas.where((item) {
      return item['hasilAkses'] == 'DITOLAK';
    }).length;

    return (jumlahGagal / aktivitas.length) * 100;
  }

  // ==========================================
  // FINGERPRINT MILIK SANTRI
  // ==========================================

  Stream<List<Map<String, dynamic>>> watchFingerprintSantri(String idSantri) {
    return _firestore
        .collection('fingerprint-mapping')
        .where('idSantri', isEqualTo: idSantri)
        .where('statusAktif', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {...doc.data(), 'documentId': doc.id};
          }).toList();
        });
  }

  // ==========================================
  // HITUNG FINGERPRINT AKTIF
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
  // BATAS MAKSIMAL 5 FINGERPRINT
  // ==========================================

  Future<bool> bisaDaftarFingerprint(String idSantri) async {
    final jumlah = await hitungFingerprintSantri(idSantri);

    return jumlah < 5;
  }

  // ==========================================
  // NONAKTIFKAN MAPPING LAMA
  // Tidak dijalankan otomatis saat enrollment.
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
  // MULAI ENROLLMENT
  // ==========================================

  Future<String> mulaiEnrollment({
    required String idSantri,
    required String namaSantri,
    required String idLocker,
    required String idPerangkat,
  }) async {
    final jumlah = await hitungFingerprintSantri(idSantri);

    if (jumlah >= 5) {
      throw Exception('Santri sudah memiliki 5 fingerprint aktif.');
    }

    final batchId =
        'B${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';

    // Siapkan konfigurasi locker untuk enrollment.
    await _firestore.collection('locker-config').doc(idLocker).set({
      'activeBatchId': batchId,
      'activeSantriId': idSantri,
      'idLocker': idLocker,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Kirim perintah enrollment ke ESP32.
    final commandRef = _firestore
        .collection('enrollment-commands')
        .doc(idPerangkat);

    await commandRef.set({
      'command': 'START_ENROLL',
      'idSantri': idSantri,
      'namaSantri': namaSantri,
      'idLocker': idLocker,
      'idPerangkat': idPerangkat,
      'batchId': batchId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return batchId;
  }

  // ==========================================
  // SIMPAN MAPPING LANGSUNG
  // Tidak membutuhkan fingerprint-pending.
  // ==========================================

  Future<void> simpanMapping({
    String? pendingDocumentId,
    required int idSensor,
    required String idFingerprint,
    required String idSantri,
    required String namaSantri,
    required String idLocker,
    required String idPerangkat,
    required String jari,
    required int urutanJari,
  }) async {
    if (idSensor <= 0) {
      throw Exception('ID sensor tidak valid.');
    }

    if (urutanJari < 1 || urutanJari > 5) {
      throw Exception('Urutan jari harus antara 1 sampai 5.');
    }

    const labelJari = {
      1: ('FP01', 'JEMPOL'),
      2: ('FP02', 'TELUNJUK'),
      3: ('FP03', 'TENGAH'),
      4: ('FP04', 'MANIS'),
      5: ('FP05', 'KELINGKING'),
    };

    final label = labelJari[urutanJari]!;

    if (idFingerprint != label.$1 || jari != label.$2) {
      throw Exception('Label fingerprint tidak sesuai dengan urutan jari.');
    }

    // Ambil batch enrollment aktif.
    final configSnapshot = await _firestore
        .collection('locker-config')
        .doc(idLocker)
        .get();

    if (!configSnapshot.exists) {
      throw Exception('Konfigurasi locker $idLocker tidak ditemukan.');
    }

    final configData = configSnapshot.data();
    final batchId = configData?['activeBatchId']?.toString() ?? '';
    final activeSantriId = configData?['activeSantriId']?.toString() ?? '';

    if (batchId.isEmpty) {
      throw Exception('Batch enrollment belum tersedia.');
    }

    if (activeSantriId != idSantri) {
      throw Exception('Santri tidak sesuai dengan sesi enrollment locker.');
    }

    // Format dokumen mapping yang dibaca ESP32.
    final documentId = '${idLocker}_${batchId}_${idFingerprint}';

    final mappingRef = _firestore
        .collection('fingerprint-mapping')
        .doc(documentId);

    // Cegah ID sensor yang sama digunakan pada mapping
    // lain dalam locker dan batch yang sama.
    final existingMappings = await _firestore
        .collection('fingerprint-mapping')
        .where('idLocker', isEqualTo: idLocker)
        .where('batchId', isEqualTo: batchId)
        .where('idSensor', isEqualTo: idSensor)
        .where('statusAktif', isEqualTo: true)
        .get();

    for (final doc in existingMappings.docs) {
      if (doc.id != documentId) {
        throw Exception(
          'ID sensor $idSensor sudah digunakan pada mapping lain.',
        );
      }
    }

    // Simpan mapping fingerprint.
    await mappingRef.set({
      'batchId': batchId,
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
    }, SetOptions(merge: true));
  }

  // ==========================================
  // SEMUA FINGERPRINT MAPPING AKTIF
  // ==========================================

  Stream<List<Map<String, dynamic>>> watchAllFingerprintMapping() {
    return _firestore
        .collection('fingerprint-mapping')
        .where('statusAktif', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {...doc.data(), 'documentId': doc.id};
          }).toList();
        });
  }
}
