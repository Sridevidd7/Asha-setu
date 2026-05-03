import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asha_setu/core/utils/constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildPage(
                color: AppColors.primary,
                icon: Icons.health_and_safety,
                title: 'Welcome to Asha-Setu',
                subtitle: 'Your Offline AI Assistant for Rural Healthcare.',
              ),
              _buildPage(
                color: AppColors.success,
                icon: Icons.record_voice_over,
                title: 'Voice-Native NLP',
                subtitle: 'Simply speak to the app, and it will fill the forms magically.',
              ),
              _buildPage(
                color: AppColors.warning,
                icon: Icons.signal_wifi_off,
                title: 'Works 100% Offline',
                subtitle: 'Data saves locally on your device and syncs securely when online.',
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage < 2)
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text('SKIP', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  )
                else
                  const SizedBox(width: 60),

                Row(
                  children: List.generate(3, (index) => 
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12)
                      ),
                    )
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    } else {
                      _finishOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(_currentPage < 2 ? 'NEXT' : 'START', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPage({required Color color, required IconData icon, required String title, required String subtitle}) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 150, color: Colors.white),
          const SizedBox(height: 48),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Colors.white70)),
        ],
      ),
    );
  }
}
