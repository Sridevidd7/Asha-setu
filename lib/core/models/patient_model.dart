class Patient {
  final String id;
  final String name;
  final int age;
  final double weight;
  final String bp;
  final String symptoms;
  final bool isPregnant;
  final int lastUpdated;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.bp,
    required this.symptoms,
    required this.isPregnant,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'weight': weight,
      'bp': bp,
      'symptoms': symptoms,
      'isPregnant': isPregnant,
      'lastUpdated': lastUpdated,
    };
  }

  factory Patient.fromMap(Map<dynamic, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] is String ? int.tryParse(map['age']) ?? 0 : map['age'] ?? 0,
      weight: map['weight'] is String ? double.tryParse(map['weight']) ?? 0.0 : (map['weight'] ?? 0).toDouble(),
      bp: map['bp'] ?? '',
      symptoms: map['symptoms'] ?? '',
      isPregnant: map['isPregnant'] ?? false,
      lastUpdated: map['lastUpdated'] ?? 0,
    );
  }
}
