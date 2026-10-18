import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/santri.dart';
import '../repositories/fingerprint_repository.dart';
import 'fingerprint_enrollment_screen.dart';

class SantriScreen extends StatelessWidget {
  SantriScreen({super.key});

  final FingerprintRepository _repository = FingerprintRepository();

  static const Color navy = Color(0xFF0B1F3A);
  static const Color navyLight = Color(0xFF163E6D);
  static const Color background = Color(0xFFF4F7FB);
  static const Color teal = Color(0xFF00897B);
  static const Color green = Color(0xFF2E7D32);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);

  // Dialog untuk Tambah / Edit Santri sesuai SKPL
  void _showSantriFormDialog(BuildContext context, {Santri? santri}) {
    final isEdit = santri != null;
    final idController = TextEditingController(text: santri?.idSantri ?? '');
    final namaController = TextEditingController(text: santri?.nama ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEdit ? 'Edit Data Santri' : 'Tambah Santri Baru',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  enabled: !isEdit, // ID Santri terkunci saat mode edit
                  decoration: InputDecoration(
                    labelText: 'ID / NIS Santri',
                    hintText: 'Contoh: ST-2026-003',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama santri',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final id = idController.text.trim();
                      final nama = namaController.text.trim();

                      if (id.isEmpty || nama.isEmpty) return;

                      setDialogState(() => isLoading = true);

                      try {
                        final docRef = FirebaseFirestore.instance
                            .collection('santri')
                            .doc(id);

                        if (!isEdit) {
                          await docRef.set({
                            'idSantri': id,
                            'nama': nama,
                            'lockerId': '',
                            'statusAktif': true,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        } else {
                          await docRef.update({
                            'nama': nama,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Data Santri',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Tombol Tambah Santri Baru (Sesuai SKPL CRUD Santri)
      floatingActionButton: FloatingActionButton(
        backgroundColor: navy,
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () => _showSantriFormDialog(context),
      ),
      body: StreamBuilder<List<Santri>>(
        stream: _repository.watchSantriAktif(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Terjadi kesalahan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final santriList = snapshot.data ?? [];

          if (santriList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 70, color: textGrey),
                  SizedBox(height: 16),
                  Text(
                    'Belum Ada Data Santri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada santri aktif di dalam sistem.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textGrey),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [navy, navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.people_alt_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daftar Santri',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${santriList.length} santri aktif',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Santri Aktif',
                style: TextStyle(
                  color: textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // LIST SANTRI
              ...santriList.map(
                (santri) => _SantriCard(
                  santri: santri,
                  repository: _repository,
                  onEdit: () => _showSantriFormDialog(context, santri: santri),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SantriCard extends StatelessWidget {
  final Santri santri;
  final FingerprintRepository repository;
  final VoidCallback onEdit;

  const _SantriCard({
    required this.santri,
    required this.repository,
    required this.onEdit,
  });

  static const Color navy = Color(0xFF0B1F3A);
  static const Color teal = Color(0xFF00897B);
  static const Color green = Color(0xFF2E7D32);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DATA SANTRI
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person, color: navy, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        santri.nama,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        santri.idSantri,
                        style: const TextStyle(color: textGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Tombol Edit Santri
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: navy, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit Santri',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Aktif',
                    style: TextStyle(
                      color: green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // LOCKER (Realtime Stream dari locker-config)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('locker-config')
                  .where('activeSantriId', isEqualTo: santri.idSantri)
                  .snapshots(),
              builder: (context, lockerSnap) {
                String activeLockerName = '-';
                if (lockerSnap.hasData && lockerSnap.data!.docs.isNotEmpty) {
                  activeLockerName = lockerSnap.data!.docs.first.id;
                }

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: teal,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Locker',
                        style: TextStyle(color: textGrey, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        activeLockerName,
                        style: TextStyle(
                          color: activeLockerName != '-'
                              ? textDark
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // FINGERPRINT STATUS (Realtime Stream dengan filter statusAktif == true)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('fingerprint-mapping')
                  .where('idSantri', isEqualTo: santri.idSantri)
                  .where('statusAktif', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 45,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final jumlah = snapshot.hasData
                    ? snapshot.data!.docs.length
                    : 0;
                final sudahMaksimal = jumlah >= 5;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fingerprint, color: teal, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'Fingerprint',
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$jumlah / 5 terdaftar',
                          style: TextStyle(
                            color: sudahMaksimal ? green : teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // PROGRESS 5 FINGERPRINT
                    Row(
                      children: List.generate(5, (index) {
                        final terisi = index < jumlah;

                        return Expanded(
                          child: Container(
                            height: 7,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: terisi ? teal : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // TOMBOL DAFTARKAN FINGER
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: sudahMaksimal
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FingerprintEnrollmentScreen(
                                          santri: santri,
                                        ),
                                  ),
                                );
                              },
                        icon: Icon(
                          sudahMaksimal
                              ? Icons.lock_outline
                              : Icons.fingerprint,
                        ),
                        label: Text(
                          sudahMaksimal
                              ? 'Maksimal 5 Fingerprint'
                              : 'Daftarkan Finger',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    if (sudahMaksimal) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Santri ini sudah memiliki 5 fingerprint aktif.',
                        style: TextStyle(color: green, fontSize: 12),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
