import 'package:cloud_firestore/cloud_firestore.dart';

class LockerActivity {
  final String id;
  final String waktuAkses;
  final String idLocker;
  final String idPerangkat;
  final String idSidikJari;
  final String idSantri;
  final String namaSantri;
  final String status;
  final String metodeAkses;
  final String dataSidikJari;
  final int tingkatKecocokan;
  final int idSensor;

  LockerActivity({
    required this.id,
    required this.waktuAkses,
    required this.idLocker,
    required this.idPerangkat,
    required this.idSidikJari,
    required this.idSantri,
    required this.namaSantri,
    required this.status,
    required this.metodeAkses,
    required this.dataSidikJari,
    required this.tingkatKecocokan,
    required this.idSensor,
  });

  factory LockerActivity.fromMap(String id, Map<String, dynamic> map) {
    String waktu = '-';

    final timestamp = map['waktuAkses'];

    if (timestamp is Timestamp) {
      waktu = timestamp.toDate().toString();
    }

    return LockerActivity(
      id: id,
      waktuAkses: waktu,
      idLocker: map['idLocker']?.toString() ?? '-',
      idPerangkat: map['idPerangkat']?.toString() ?? '-',
      idSidikJari: map['idSidikJari']?.toString() ?? '-',
      idSantri: map['idSantri']?.toString() ?? '-',
      namaSantri: map['namaSantri']?.toString() ?? '-',
      status: map['status']?.toString() ?? '-',
      metodeAkses: map['metodeAkses']?.toString() ?? '-',
      dataSidikJari: map['dataSidikJari']?.toString() ?? '-',
      tingkatKecocokan: (map['tingkatKecocokan'] as num?)?.toInt() ?? 0,
      idSensor: (map['idSensor'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isGranted => status.toLowerCase() == 'diterima';
}
