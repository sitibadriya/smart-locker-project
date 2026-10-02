import 'package:flutter/material.dart';

import '../models/locker_activity.dart';

class LockerActivityCard extends StatelessWidget {
  final LockerActivity activity;

  const LockerActivityCard({Key? key, required this.activity})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activity.isGranted ? Colors.green : Colors.red,
          child: Icon(
            activity.isGranted ? Icons.lock_open : Icons.lock,
            color: Colors.white,
          ),
        ),
        title: Text(
          activity.namaSantri,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loker: ${activity.idLocker}'),
            Text('ID Santri: ${activity.idSantri}'),
            Text('Sidik Jari: ${activity.idSidikJari}'),
            Text('Keterangan: ${activity.dataSidikJari}'),
            Text('Kecocokan: ${activity.tingkatKecocokan}'),
            Text('Waktu: ${activity.waktuAkses}'),
          ],
        ),
        trailing: Text(
          activity.status.toUpperCase(),
          style: TextStyle(
            color: activity.isGranted
                ? Colors.green.shade800
                : Colors.red.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
