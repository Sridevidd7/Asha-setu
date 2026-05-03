import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'database_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _db = DatabaseService();
  StreamSubscription? _connectivitySubscription;

  void listenToConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        syncWithFirebase();
      }
    });
  }

  Future<void> syncWithFirebase() async {
    try {
      // 1. Sync Patients Collection
      final localPatientsMap = _db.getPatients().map((p) => p.toMap()).toList();
      await _syncCollection('patients', localPatientsMap, _db.patientsBox);

      // 2. Sync Vaccinations Collection
      final localVacsMap = _db.getVaccinations().map((v) => v.toMap()).toList();
      await _syncCollection('vaccinations', localVacsMap, _db.vaccinationsBox);

    } catch (e) {
      print('Sync failed: $e');
    }
  }

  Future<void> _syncCollection(String colName, List<Map<String, dynamic>> localRecords, Box localBox) async {
    final cloudSnapshot = await _firestore.collection(colName).get();
    final cloudRecords = cloudSnapshot.docs;

    Map<String, Map<String, dynamic>> cloudMap = {
      for (var doc in cloudRecords) doc.id: doc.data()
    };

    // 1. Upload local changes that are newer or don't exist in cloud
    for (var localData in localRecords) {
      final cloudData = cloudMap[localData['id']];
      if (cloudData == null || (localData['lastUpdated'] ?? 0) > (cloudData['lastUpdated'] ?? 0)) {
        await _firestore.collection(colName).doc(localData['id']).set(localData);
      }
    }

    // 2. Download cloud changes that are newer
    for (var cloudDoc in cloudRecords) {
      final cData = cloudDoc.data();
      final cId = cloudDoc.id;
      final cTimestamp = cData['lastUpdated'] ?? 0;

      final localMatchList = localRecords.where((p) => p['id'] == cId).toList();
      if (localMatchList.isEmpty || cTimestamp > (localMatchList.first['lastUpdated'] ?? 0)) {
        await localBox.put(cId, cData);
      }
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
