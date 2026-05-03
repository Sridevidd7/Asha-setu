import 'package:flutter/material.dart';
import 'package:asha_setu/core/utils/constants.dart';
import 'package:asha_setu/core/models/patient_model.dart';
import 'package:asha_setu/core/services/database_service.dart';
import 'package:asha_setu/core/services/ai_rule_engine.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vaccinations = DatabaseService().getVaccinations();
    final alerts = AIRuleEngine.evaluatePatient(patient, vaccinations);
    
    // Determine overall color by checking the primary (top) alert severity (Index 0 is highest since we sorted)
    Color appBarColor = AppColors.success;
    if (alerts.isNotEmpty) {
      if (alerts.first.severity == AlertSeverity.high) appBarColor = AppColors.alert;
      else if (alerts.first.severity == AlertSeverity.medium) appBarColor = AppColors.warning;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Render Dynamic AI Alerts Sequence
            for (var alert in alerts)
              if (alert.severity != AlertSeverity.normal)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: alert.severity == AlertSeverity.high ? AppColors.alert.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: alert.severity == AlertSeverity.high ? AppColors.alert : AppColors.warning, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.health_and_safety, color: alert.severity == AlertSeverity.high ? AppColors.alert : AppColors.warning, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          alert.message,
                          style: TextStyle(
                            color: alert.severity == AlertSeverity.high ? AppColors.alert : AppColors.warning, 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(patient.name.isNotEmpty ? patient.name : 'Unknown Name', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text('ID: ${patient.id}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 32),
            
            _buildInfoRow(Icons.cake, 'Age', '${patient.age} Years'),
            const Divider(height: 32),
            _buildInfoRow(Icons.monitor_weight, 'Weight', '${patient.weight} Kg'),
            const Divider(height: 32),
            _buildInfoRow(Icons.favorite, 'Blood Pressure', patient.bp.isNotEmpty ? patient.bp : '--', highlight: alerts.any((a) => a.message.contains('Hypertension'))),
            const Divider(height: 32),
            _buildInfoRow(Icons.sick, 'Reported Symptoms', patient.symptoms.isNotEmpty ? patient.symptoms : 'None', maxLines: 3),
            const Divider(height: 32),
            _buildInfoRow(Icons.pregnant_woman, 'Pregnancy Status', patient.isPregnant ? 'Pregnant' : 'Not Pregnant', highlight: alerts.any((a) => a.message.contains('Pregnancy'))),
            
            const SizedBox(height: 48),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 28),
              label: const Text('Update Background', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool highlight = false, int maxLines = 1}) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 36, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                  color: highlight ? AppColors.alert : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
