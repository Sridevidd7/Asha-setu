import 'package:flutter/material.dart';
import 'package:asha_setu/core/utils/constants.dart';
import 'add_patient_screen.dart';
import 'patient_records_screen.dart';
import 'package:asha_setu/features/vaccinations/presentation/screens/vaccination_tracker_screen.dart';
import 'package:asha_setu/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:asha_setu/features/hospitals/presentation/screens/nearby_hospitals_screen.dart';
import 'package:asha_setu/core/services/localization_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.currentLocale,
      builder: (context, locale, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.dashboard),
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.language, size: 30),
                tooltip: 'Toggle Kannada/English',
                onPressed: LocalizationService.toggleLanguage,
              )
            ],
          ),
          body: GridView.count(
            padding: const EdgeInsets.all(24.0),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                context,
                title: AppStrings.addPatient,
                icon: Icons.person_add_alt_1,
                color: AppColors.primary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPatientScreen())),
              ),
              _buildDashboardCard(
                context,
                title: AppStrings.viewRecords,
                icon: Icons.folder_shared,
                color: Colors.blue[700]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientRecordsScreen())),
              ),
              _buildDashboardCard(
                context,
                title: AppStrings.vaccinationTracker,
                icon: Icons.vaccines,
                color: AppColors.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationTrackerScreen())),
              ),
              _buildDashboardCard(
                context,
                title: AppStrings.analytics,
                icon: Icons.bar_chart,
                color: AppColors.warning,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
              ),
              _buildDashboardCard(
                context,
                title: AppStrings.nearbyHospitals,
                icon: Icons.local_hospital,
                color: AppColors.alert,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyHospitalsScreen())),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: color.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
