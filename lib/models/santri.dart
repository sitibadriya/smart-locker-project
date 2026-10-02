import 'package:cloud_firestore/cloud_firestore.dart';

class Santri {
  final String id;
  final String nama;
  final String idSantri;
  final String lockerId;
  final List<String> fingerprintIds;
  final bool statusAktif;
  final DateTime? registeredAt;

  Santri({
    required this.id,
    required this.nama,
    required this.idSantri,
    required this.lockerId,
    required this.fingerprintIds,
    required this.statusAktif,
    required this.registeredAt,
  });

  factory Santri.fromMap(String id, Map<String, dynamic> map) {
    final fingerprintData = map['fingerprintIds'];

    List<String> fingerprintIds = [];

    if (fingerprintData is List) {
      fingerprintIds = fingerprintData.map((item) => item.toString()).toList();
    }

    DateTime? registeredAt;

    final timestamp = map['registeredAt'];

    if (timestamp is Timestamp) {
      registeredAt = timestamp.toDate();
    }

    return Santri(
      id: id,
      nama: map['nama']?.toString() ?? 'Tanpa Nama',
      idSantri: map['idSantri']?.toString() ?? '-',
      lockerId: map['lockerId']?.toString() ?? '-',
      fingerprintIds: fingerprintIds,
      statusAktif: map['statusAktif'] == true,
      registeredAt: registeredAt,
    );
  }
}
