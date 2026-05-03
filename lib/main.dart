import 'package:flutter/material.dart';
import 'core/services/localization_service.dart';
import 'core/utils/constants.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AshaSetuApp());
}

class AshaSetuApp extends StatelessWidget {
  const AshaSetuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.currentLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Asha-Setu',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'Roboto',
          ),
          home: const SplashScreen(),
        );
      }
    );
  }
}
