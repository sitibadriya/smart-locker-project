class LockerActivity {
  final String id;
  final String dataFP;
  final String lockerId;
  final String fingerprintId; // Tipe data String
  final String status;

  LockerActivity({
    required this.id,
    required this.dataFP,
    required this.lockerId,
    required this.fingerprintId,
    required this.status,
  });

  factory LockerActivity.fromMap(String id, Map<String, dynamic> map) {
    return LockerActivity(
      id: id,
      dataFP: map['Data_FP']?.toString() ?? 'Aktivitas Akses',
      lockerId: map['lockerId']?.toString() ?? '-',
      fingerprintId: map['fingerprintId']?.toString() ?? '-', // Gunakan .toString() tanpa casting (as num?)
      status: (map['status'] ?? 'denied').toString(),
    );
  }

  bool get isGranted => status.toLowerCase() == 'granted';
}