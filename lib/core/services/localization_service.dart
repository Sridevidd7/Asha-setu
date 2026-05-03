import 'package:flutter/foundation.dart';

class LocalizationService {
  static final ValueNotifier<String> currentLocale = ValueNotifier('en');

  static void toggleLanguage() {
    currentLocale.value = currentLocale.value == 'en' ? 'kn' : 'en';
  }

  static String get(String key) {
    return _localizedValues[currentLocale.value]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Asha-Setu',
      'dashboard': 'Dashboard',
      'addPatient': 'Add Patient',
      'viewRecords': 'Patient Records',
      'vaccinationTracker': 'Vaccination Tracker',
      'analytics': 'Analytics Dashboard',
      'nearbyHospitals': 'Nearby Hospitals',
      'searchPatient': 'Search Patient',
      'login': 'Login with Phone',
      'enterPhone': 'Enter Phone Number',
      'sendOtp': 'Send OTP',
      'enterOtp': 'Enter OTP',
      'verify': 'Verify',
      'save': 'Save Patient',
    },
    'kn': {
      'appName': 'ಆಶಾ-ಸೇತು',
      'dashboard': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
      'addPatient': 'ರೋಗಿಯನ್ನು ಸೇರಿಸಿ',
      'viewRecords': 'ರೋಗಿಗಳ ದಾಖಲೆಗಳು',
      'vaccinationTracker': 'ಲಸಿಕೆ ಟ್ರ್ಯಾಕರ್',
      'analytics': 'ವಿಶ್ಲೇಷಣೆ',
      'nearbyHospitals': 'ಹತ್ತಿರದ ಆಸ್ಪತ್ರೆಗಳು',
      'searchPatient': 'ರೋಗಿಯನ್ನು ಹುಡುಕಿ',
      'login': 'ಫೋನ್ ಮೂಲಕ ಲಾಗಿನ್ ಮಾಡಿ',
      'enterPhone': 'ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      'sendOtp': 'OTP ಕಳುಹಿಸಿ',
      'enterOtp': 'OTP ನಮೂದಿಸಿ',
      'verify': 'ಪರಿಶೀಲಿಸಿ',
      'save': 'ರೋಗಿಯನ್ನು ಉಳಿಸಿ',
    }
  };
}
