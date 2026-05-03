import 'package:hive_flutter/hive_flutter.dart';
import 'package:asha_setu/core/models/patient_model.dart';
import 'package:asha_setu/core/models/vaccination_model.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _uuid = const Uuid();
  Box? _patientsBox;
  Box? _vaccinationsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _patientsBox = await Hive.openBox('patients');
    _vaccinationsBox = await Hive.openBox('vaccinations');
  }

  Box get patientsBox => _patientsBox!;
  Box get vaccinationsBox => _vaccinationsBox!;

  // ---------------- PATIENTS ----------------

  List<Patient> getPatients() {
    return _patientsBox!.values.map((map) => Patient.fromMap(map)).toList();
  }

  Future<void> addPatient(Patient patient) async {
    await _patientsBox!.put(patient.id, patient.toMap());
  }

  Future<void> updatePatient(Patient patient) async {
    await _patientsBox!.put(patient.id, patient.toMap());
  }

  Future<void> deletePatient(String id) async {
    await _patientsBox!.delete(id);
  }

  Patient generateNewPatient({
    required String name,
    required int age,
    required double weight,
    required String bp,
    required String symptoms,
    required bool isPregnant,
  }) {
    return Patient(
      id: _uuid.v4(),
      name: name,
      age: age,
      weight: weight,
      bp: bp,
      symptoms: symptoms,
      isPregnant: isPregnant,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ---------------- VACCINATIONS ----------------

  List<Vaccination> getVaccinations() {
    return _vaccinationsBox!.values.map((map) => Vaccination.fromMap(map)).toList();
  }

  Future<void> addVaccination(Vaccination vac) async {
    await _vaccinationsBox!.put(vac.id, vac.toMap());
  }

  Future<void> updateVaccination(Vaccination vac) async {
    await _vaccinationsBox!.put(vac.id, vac.toMap());
  }
}
