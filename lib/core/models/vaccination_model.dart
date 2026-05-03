class Vaccination {
  final String id;
  final String patientId;
  final String vaccineName;
  final int date;
  final bool isCompleted;
  final int lastUpdated;

  Vaccination({
    required this.id,
    required this.patientId,
    required this.vaccineName,
    required this.date,
    required this.isCompleted,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'vaccineName': vaccineName,
      'date': date,
      'isCompleted': isCompleted,
      'lastUpdated': lastUpdated,
    };
  }

  factory Vaccination.fromMap(Map<dynamic, dynamic> map) {
    return Vaccination(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      vaccineName: map['vaccineName'] ?? '',
      date: map['date'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      lastUpdated: map['lastUpdated'] ?? 0,
    );
  }
}
