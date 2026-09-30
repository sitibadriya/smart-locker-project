import 'package:flutter/material.dart';
import '../models/santri.dart';

class SantriCard extends StatelessWidget {
  final Santri santri;

  const SantriCard({Key? key, required this.santri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          santri.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'ID Santri: ${santri.idSantri} | Loker: ${santri.lockerId}',
        ),
      ),
    );
  }
}