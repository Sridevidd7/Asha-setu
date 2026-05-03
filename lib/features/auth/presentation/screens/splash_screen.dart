import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:asha_setu/core/services/database_service.dart';
import 'package:asha_setu/core/services/sync_service.dart';
import 'package:asha_setu/core/utils/constants.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'package:asha_setu/features/patients/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Firebase.initializeApp();
      await DatabaseService().init();
      SyncService().listenToConnectivity();

      final prefs = await SharedPreferences.getInstance();
      bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      
      Widget nextScreen;
      if (isFirstLaunch) {
        nextScreen = const OnboardingScreen();
      } else if (FirebaseAuth.instance.currentUser != null) {
        nextScreen = const HomeScreen();
      } else {
        nextScreen = const LoginScreen();
      }

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 100, color: Colors.white),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
