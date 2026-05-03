import 'package:asha_setu/core/models/patient_model.dart';
import 'package:asha_setu/core/models/vaccination_model.dart';

enum AlertSeverity { high, medium, normal }

class HealthAlert {
  final String message;
  final AlertSeverity severity;
  HealthAlert({required this.message, required this.severity});
}

class AIRuleEngine {
  static List<HealthAlert> evaluatePatient(Patient patient, List<Vaccination> vaccinations) {
    List<HealthAlert> alerts = [];

    // 1. BP Check: > 140 -> "Hypertension Risk"
    if (patient.bp.isNotEmpty) {
      final parts = patient.bp.split(RegExp(r'[/_ over]'));
      if (parts.isNotEmpty) {
        int? systolic = int.tryParse(parts[0].trim());
        if (systolic != null && systolic > 140) {
          alerts.add(HealthAlert(message: 'Hypertension Risk (BP: ${patient.bp})', severity: AlertSeverity.high));
        }
      }
    }

    // 2. Pregnancy + Low Weight (< 45) -> "High Risk Pregnancy"
    if (patient.isPregnant && patient.weight > 0 && patient.weight < 45.0) {
      alerts.add(HealthAlert(message: 'High Risk Pregnancy (Low Weight)', severity: AlertSeverity.high));
    }

    // 3. Fever + Cough -> "Possible infection"
    String symp = patient.symptoms.toLowerCase();
    if (symp.contains('fever') && symp.contains('cough')) {
      alerts.add(HealthAlert(message: 'Possible Infection (Fever + Cough)', severity: AlertSeverity.medium));
    }

    // 4. Vaccination Missed
    final now = DateTime.now().millisecondsSinceEpoch;
    bool missed = false;
    for (var vac in vaccinations) {
      if (vac.patientId == patient.id && !vac.isCompleted && vac.date < now) {
        missed = true;
        break;
      }
    }
    if (missed) {
      alerts.add(HealthAlert(message: 'Missed Vaccination Schedule', severity: AlertSeverity.high));
    }

    if (alerts.isEmpty) {
      alerts.add(HealthAlert(message: 'Status Normal', severity: AlertSeverity.normal));
    }

    // Sort by severity (high = 0, medium = 1, normal = 2)
    alerts.sort((a, b) => a.severity.index.compareTo(b.severity.index));
    return alerts;
  }
}
