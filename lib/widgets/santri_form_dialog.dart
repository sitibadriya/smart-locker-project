import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/santri.dart';

class SantriFormDialog extends StatefulWidget {
  final Santri? santri; // Null jika Tambah, terisi jika Edit

  const SantriFormDialog({super.key, this.santri});

  @override
  State<SantriFormDialog> createState() => _SantriFormDialogState();
}

class _SantriFormDialogState extends State<SantriFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idSantriController;
  late TextEditingController _namaController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _idSantriController = TextEditingController(
      text: widget.santri?.idSantri ?? '',
    );
    _namaController = TextEditingController(
      text: widget.santri?.nama ?? '',
    );
  }

  @override
  void dispose() {
    _idSantriController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _saveSantri() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final idSantri = _idSantriController.text.trim();
      final nama = _namaController.text.trim();

      final docRef =
          FirebaseFirestore.instance.collection('santri').doc(idSantri);

      if (widget.santri == null) {
        // CREATE SANTRI BARU
        await docRef.set({
          'idSantri': idSantri,
          'nama': nama,
          'lockerId': '',
          'statusAktif': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // UPDATE SANTRI
        await docRef.update({
          'nama': nama,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.santri == null
                  ? 'Santri berhasil ditambahkan'
                  : 'Data santri berhasil diperbarui',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.santri != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEdit ? 'Edit Data Santri' : 'Tambah Santri Baru',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _idSantriController,
                enabled: !isEdit, // ID Santri tidak boleh diubah saat edit
                decoration: InputDecoration(
                  labelText: 'ID / NIS Santri',
                  hintText: 'Contoh: ST-2026-003',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'ID Santri wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama santri',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama santri wajib diisi';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSantri,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B1F3A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
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
    );
  }
}
