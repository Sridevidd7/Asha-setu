import 'package:flutter/material.dart';
import 'package:asha_setu/core/utils/constants.dart';
import 'patient_detail_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:asha_setu/core/services/database_service.dart';
import 'package:asha_setu/core/services/ai_rule_engine.dart';
import 'package:asha_setu/core/models/patient_model.dart';

class PatientRecordsScreen extends StatelessWidget {
  const PatientRecordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.viewRecords),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: AppStrings.searchPatient,
                prefixIcon: const Icon(Icons.search, size: 32),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: DatabaseService().patientsBox.listenable(),
              builder: (context, box, _) {
                final patients = DatabaseService().getPatients();
                if (patients.isEmpty) {
                  return const Center(child: Text('No patient records found.', style: TextStyle(fontSize: 18)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    final allVacs = DatabaseService().getVaccinations();
                    final alerts = AIRuleEngine.evaluatePatient(patient, allVacs);
                    final topAlert = alerts.first;
                    
                    Color cardColor;
                    IconData cardIcon;
                    if (topAlert.severity == AlertSeverity.high) {
                      cardColor = AppColors.alert;
                      cardIcon = Icons.warning_rounded;
                    } else if (topAlert.severity == AlertSeverity.medium) {
                      cardColor = AppColors.warning;
                      cardIcon = Icons.error_outline;
                    } else {
                      cardColor = AppColors.success;
                      cardIcon = Icons.check_circle;
                    }

                    return Card(
                      elevation: 4,
                      shadowColor: Colors.black26,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: cardColor.withOpacity(0.2),
                          child: Icon(
                            cardIcon,
                            size: 32,
                            color: cardColor,
                          ),
                        ),
                        title: Text(
                          patient.name.isNotEmpty ? patient.name : 'Unknown Patient',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            topAlert.message,
                            style: TextStyle(
                              fontSize: 18,
                              color: cardColor,
                              fontWeight: topAlert.severity != AlertSeverity.normal ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 24),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
