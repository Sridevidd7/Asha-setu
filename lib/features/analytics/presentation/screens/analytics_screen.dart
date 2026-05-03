import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:asha_setu/core/utils/constants.dart';
import 'package:asha_setu/core/services/database_service.dart';
import 'package:asha_setu/core/services/ai_rule_engine.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  Map<String, int> _computeSymptomFrequencies() {
    final patients = DatabaseService().getPatients();
    int fever = 0, cough = 0, weakness = 0, pain = 0;

    for (var p in patients) {
      String sym = p.symptoms.toLowerCase();
      if (sym.contains('fever')) fever++;
      if (sym.contains('cough')) cough++;
      if (sym.contains('weak')) weakness++;
      if (sym.contains('pain') || sym.contains('ache')) pain++;
    }
    
    // Fallbacks if no data to ensure chart renders
    if (fever == 0 && cough == 0 && weakness == 0 && pain == 0) {
       return {'Fever': 1, 'Cough': 1, 'Weakness': 1, 'Pain': 1}; 
    }

    return {'Fever': fever, 'Cough': cough, 'Weakness': weakness, 'Pain': pain};
  }

  int _computeHighRiskCount() {
    final patients = DatabaseService().getPatients();
    final vacs = DatabaseService().getVaccinations();
    int count = 0;

    for (var p in patients) {
      final alerts = AIRuleEngine.evaluatePatient(p, vacs);
      if (alerts.isNotEmpty && alerts.first.severity == AlertSeverity.high) {
        count++;
      }
    }
    return count;
  }

  Map<String, double> _computeVaccinationRates() {
    final vacs = DatabaseService().getVaccinations();
    if (vacs.isEmpty) return {'Completed': 50.0, 'Pending': 50.0, 'Missed': 0.0};

    int completed = 0, pending = 0, missed = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var v in vacs) {
      if (v.isCompleted) {
        completed++;
      } else if (v.date < now) {
        missed++;
      } else {
        pending++;
      }
    }
    return {
      'Completed': (completed / vacs.length) * 100,
      'Pending': (pending / vacs.length) * 100,
      'Missed': (missed / vacs.length) * 100,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.analytics),
        backgroundColor: AppColors.warning,
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: DatabaseService().patientsBox.listenable(),
        builder: (context, _, __) {
          return ValueListenableBuilder<Box>(
            valueListenable: DatabaseService().vaccinationsBox.listenable(),
            builder: (context, _, __) {
              
              final highRiskCount = _computeHighRiskCount();
              final freqMap = _computeSymptomFrequencies();
              final vacMap = _computeVaccinationRates();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // High Risk Aggregate Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                         color: AppColors.alert.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: AppColors.alert, width: 2)
                      ),
                      child: Column(
                        children: [
                           const Text('TOTAL HIGH-RISK PATIENTS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.alert)),
                           const SizedBox(height: 8),
                           Text('$highRiskCount', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppColors.alert)),
                        ]
                      )
                    ),
                    const SizedBox(height: 48),

                    const Text(
                      'Common Diseases (Live)',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (freqMap.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
                                  String text = freqMap.keys.elementAt(value.toInt());
                                  return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: style));
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            for (int i = 0; i < freqMap.length; i++)
                              BarChartGroupData(
                                x: i, 
                                barRods: [BarChartRodData(toY: freqMap.values.elementAt(i).toDouble(), color: AppColors.warning, width: 24, borderRadius: BorderRadius.zero)]
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),
                    const Text(
                      'Vaccination Completion Rates',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: [
                            if (vacMap['Completed']! > 0)
                              PieChartSectionData(color: AppColors.success, value: vacMap['Completed']!, title: '${vacMap['Completed']!.toStringAsFixed(1)}%', radius: 60, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            if (vacMap['Pending']! > 0)
                              PieChartSectionData(color: AppColors.warning, value: vacMap['Pending']!, title: '${vacMap['Pending']!.toStringAsFixed(1)}%', radius: 60, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            if (vacMap['Missed']! > 0)
                              PieChartSectionData(color: AppColors.alert, value: vacMap['Missed']!, title: '${vacMap['Missed']!.toStringAsFixed(1)}%', radius: 70, titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLegend(AppColors.success, 'Completed'),
                    _buildLegend(AppColors.warning, 'Pending'),
                    _buildLegend(AppColors.alert, 'Missed Target'),
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 24, height: 24, color: color),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
