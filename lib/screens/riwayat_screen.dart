import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  static const Color navy = Color(0xFF0B1F3A);
  static const Color navyLight = Color(0xFF163E6D);
  static const Color background = Color(0xFFF4F7FB);
  static const Color teal = Color(0xFF00897B);
  static const Color green = Color(0xFF2E7D32);
  static const Color red = Color(0xFFC62828);
  static const Color darkText = Color(0xFF172033);
  static const Color grey = Color(0xFF6B7280);
  static const Color border = Color(0xFFE7ECF3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Akses',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('locker-activity')
            .orderBy('waktu', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat riwayat akses.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: navy));
          }

          final docs = snapshot.data?.docs ?? [];

          final diizinkan = docs
              .where((doc) => doc.data()['hasilAkses'] == 'DIIZINKAN')
              .length;

          final ditolak = docs
              .where((doc) => doc.data()['hasilAkses'] == 'DITOLAK')
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
            children: [
              // Header ringkas
              const Text(
                'Aktivitas Locker',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pantau catatan akses locker santri.',
                style: TextStyle(fontSize: 13, color: grey),
              ),

              const SizedBox(height: 22),

              // Ringkasan statistik
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Diizinkan',
                      value: '$diizinkan',
                      accent: green,
                      iconBackground: const Color(0xFFE5F3E9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      icon: Icons.cancel_outlined,
                      label: 'Ditolak',
                      value: '$ditolak',
                      accent: red,
                      iconBackground: const Color(0xFFFFEAEA),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Judul daftar
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: teal,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'Aktivitas Terbaru',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                  ),
                  Text(
                    '${docs.length} catatan',
                    style: const TextStyle(fontSize: 12, color: grey),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (docs.isEmpty)
                const _EmptyHistory()
              else
                ...docs.map((doc) => _historyCard(doc.data())),
            ],
          );
        },
      ),
    );
  }

  static Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 23),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 11, color: grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _historyCard(Map<String, dynamic> data) {
    final hasil = (data['hasilAkses'] ?? '').toString();
    final isAllowed = hasil == 'DIIZINKAN';
    final isDenied = hasil == 'DITOLAK';

    final nama = (data['namaSantri'] ?? 'Tidak diketahui').toString();
    final fingerprint = (data['idFingerprint'] ?? '-').toString();
    final locker = (data['idLocker'] ?? '-').toString();
    final idSantri = (data['idSantri'] ?? '-').toString();
    final keterangan = (data['keterangan'] ?? '-').toString();

    final waktu = data['waktu'];
    final tanggal = waktu is Timestamp ? waktu.toDate() : null;

    final tanggalTeks = tanggal == null
        ? 'Waktu tidak tersedia'
        : '${tanggal.day.toString().padLeft(2, '0')} '
              '${_namaBulan(tanggal.month)} ${tanggal.year}';

    final jamTeks = tanggal == null
        ? ''
        : '${tanggal.hour.toString().padLeft(2, '0')}:'
              '${tanggal.minute.toString().padLeft(2, '0')}';

    final warnaStatus = isAllowed
        ? green
        : isDenied
        ? red
        : grey;

    final latarStatus = isAllowed
        ? const Color(0xFFE5F3E9)
        : isDenied
        ? const Color(0xFFFFEAEA)
        : const Color(0xFFF0F2F5);

    final teksStatus = isAllowed
        ? 'Diizinkan'
        : isDenied
        ? 'Ditolak'
        : 'Tidak diketahui';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identitas santri dan status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0F8),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: navyLight,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$tanggalTeks${jamTeks.isNotEmpty ? ' • $jamTeks' : ''}',
                      style: const TextStyle(color: grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: latarStatus,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  teksStatus,
                  style: TextStyle(
                    color: warnaStatus,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: border),
          const SizedBox(height: 13),

          // Informasi locker dan fingerprint
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  Icons.meeting_room_outlined,
                  'Locker',
                  locker,
                ),
              ),
              Expanded(
                child: _detailItem(
                  Icons.fingerprint_rounded,
                  'Fingerprint',
                  fingerprint,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // Keterangan singkat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: teal),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  keterangan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: grey,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text(
            'ID Santri: $idSantri',
            style: const TextStyle(color: grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static Widget _detailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 17, color: teal),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: grey)),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _namaBulan(int bulan) {
    const bulanList = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return bulanList[bulan - 1];
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: Color(0xFF9AA8BC)),
          SizedBox(height: 14),
          Text(
            'Belum Ada Aktivitas',
            style: TextStyle(
              color: Color(0xFF172033),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Riwayat akses akan muncul otomatis '
            'setelah ada aktivitas fingerprint.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
