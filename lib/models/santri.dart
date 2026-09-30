class Santri {
  final String id;
  final String nama;
  final String idSantri;
  final String lockerId;

  Santri({
    required this.id,
    required this.nama,
    required this.idSantri,
    required this.lockerId,
  });

  factory Santri.fromMap(String id, Map<String, dynamic> map) {
    return Santri(
      id: id,
      nama: map['nama']?.toString() ?? 'Tanpa Nama',
      idSantri: map['idSantri']?.toString() ?? '-',
      lockerId: map['lockerId']?.toString() ?? '-',
    );
  }
}