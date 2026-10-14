class EnrollmentCommand {
  final String idSantri;
  final String namaSantri;
  final String idLocker;
  final String idPerangkat;

  EnrollmentCommand({
    required this.idSantri,
    required this.namaSantri,
    required this.idLocker,
    required this.idPerangkat,
  });

  Map<String, dynamic> toMap() {
    return {
      'command': 'START_ENROLL',
      'idSantri': idSantri,
      'namaSantri': namaSantri,
      'idLocker': idLocker,
      'idPerangkat': idPerangkat,
      'status': 'pending',
    };
  }
}
