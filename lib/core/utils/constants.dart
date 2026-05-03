import 'package:flutter/material.dart';
import 'package:asha_setu/core/services/localization_service.dart';

class AppColors {
  static const Color primary = Color(0xFF00BFA5); // Teal accent
  static const Color primaryLight = Color(0xFFB2DFDB);
  static const Color background = Color(0xFFF5F5F5);
  
  static const Color alert = Color(0xFFE53935); // Critical Risk
  static const Color warning = Color(0xFFFFB300); // Medium Risk
  static const Color success = Color(0xFF43A047); // Normal
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

class AppStrings {
  static String get appName => LocalizationService.get('appName');
  static String get dashboard => LocalizationService.get('dashboard');
  static String get addPatient => LocalizationService.get('addPatient');
  static String get viewRecords => LocalizationService.get('viewRecords');
  static String get vaccinationTracker => LocalizationService.get('vaccinationTracker');
  static String get analytics => LocalizationService.get('analytics');
  static String get nearbyHospitals => LocalizationService.get('nearbyHospitals');
  static String get searchPatient => LocalizationService.get('searchPatient');

  static String get login => LocalizationService.get('login');
  static String get enterPhone => LocalizationService.get('enterPhone');
  static String get sendOtp => LocalizationService.get('sendOtp');
  static String get enterOtp => LocalizationService.get('enterOtp');
  static String get verify => LocalizationService.get('verify');
  static String get save => LocalizationService.get('save');
}
