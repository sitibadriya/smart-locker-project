class Santri {
  final String idSantri;
  final String nama;
  final String lockerId;
  final bool statusAktif;

  Santri({
    required this.idSantri,
    required this.nama,
    required this.lockerId,
    required this.statusAktif,
  });

  factory Santri.fromFirestore(Map<String, dynamic> data) {
    return Santri(
      idSantri: data['idSantri'] ?? '',
      nama: data['nama'] ?? '',
      lockerId: data['lockerId'] ?? '',
      statusAktif: data['statusAktif'] ?? false,
    );
  }
}
