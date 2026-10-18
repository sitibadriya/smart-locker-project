import 'package:cloud_firestore/cloud_firestore.dart';

class LockerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Perintah Buka Loker Jarak Jauh (Remote Unlock)
  Future<void> sendRemoteUnlockCommand(String idLocker) async {
    await _firestore.collection('locker-config').doc(idLocker).update({
      'remoteCommand': 'UNLOCK',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Perintah Reset / Ganti Pemilik Loker
  Future<void> sendResetLockerCommand(String idLocker) async {
    await _firestore.collection('locker-config').doc(idLocker).update({
      'resetCommand': 'RESET_OWNER',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Perintah Pendaftaran Sidik Jari Baru (Start Enroll)
  Future<void> startEnrollment({
    required String idPerangkat,
    required String idLocker,
    required String idSantri,
    required String namaSantri,
  }) async {
    await _firestore.collection('enrollment-commands').doc(idPerangkat).set({
      'command': 'START_ENROLL',
      'status': 'pending',
      'idPerangkat': idPerangkat,
      'idLocker': idLocker,
      'idSantri': idSantri,
      'namaSantri': namaSantri,
      'errorMessage': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
