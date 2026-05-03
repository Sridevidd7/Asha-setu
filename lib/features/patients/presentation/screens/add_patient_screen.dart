import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:asha_setu/core/utils/constants.dart';
import 'package:asha_setu/core/services/database_service.dart';
import 'package:asha_setu/core/services/localization_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({Key? key}) : super(key: key);

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcription = '';
  
  bool _isPregnant = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _bpCtrl = TextEditingController();
  final TextEditingController _symptomsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        String localeTarget = LocalizationService.currentLocale.value == 'kn' ? 'kn-IN' : 'en-IN';
        _speech.listen(
          onResult: (val) {
            setState(() {
              _transcription = val.recognizedWords;
              _processVoiceData(_transcription);
            });
          },
          localeId: localeTarget,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processVoiceData(String text) {
    String lowerText = text.toLowerCase();

    // Parse Age
    final ageMatch = RegExp(r'age (?:is )?(\d+)').firstMatch(lowerText);
    if (ageMatch != null) _ageCtrl.text = ageMatch.group(1)!;

    // Parse Weight
    final weightMatch = RegExp(r'weight (?:is )?(\d+)').firstMatch(lowerText);
    if (weightMatch != null) _weightCtrl.text = weightMatch.group(1)!;

    // Parse Blood Pressure (matches forms like "120 over 80", "120/80")
    final bpMatch = RegExp(r'(?:blood pressure|bp) (?:is )?(\d+)[\s/o\D]+(\d+)').firstMatch(lowerText);
    if (bpMatch != null) _bpCtrl.text = '${bpMatch.group(1)}/${bpMatch.group(2)}';

    // Parse Name ("name is John Doe...")
    final nameMatch = RegExp(r'name is ([a-z ]+?)(?: and|,| age| weight| blood| symptom|$)').firstMatch(lowerText);
    if (nameMatch != null) {
      String name = nameMatch.group(1)!.trim();
      _nameCtrl.text = name.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' ');
    }

    // Parse Symptoms ("symptoms are fever and cough...")
    final sympMatch = RegExp(r'symptoms (?:are |include )?([a-z ]+?)(?: and|,| name| age| weight| blood|$)').firstMatch(lowerText);
    if (sympMatch != null) _symptomsCtrl.text = sympMatch.group(1)!.trim();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.currentLocale,
      builder: (context, locale, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.addPatient),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Voice Input Section
                GestureDetector(
                  onTap: _listen,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 140,
                    decoration: BoxDecoration(
                      color: _isListening ? AppColors.alert : AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (_isListening)
                          BoxShadow(color: AppColors.alert.withOpacity(0.4), blurRadius: 15, spreadRadius: 5)
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isListening ? Icons.mic : Icons.mic_none, size: 48, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          _isListening ? 'Listening... Tap to stop' : 'Tap & Speak',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (_transcription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Transcription: "$_transcription"',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800], fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 24),
                
                // Manual Forms Section
                _buildLargeTextField(controller: _nameCtrl, label: 'Name', icon: Icons.person),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildLargeTextField(controller: _ageCtrl, label: 'Age', icon: Icons.cake, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLargeTextField(controller: _weightCtrl, label: 'Weight (kg)', icon: Icons.monitor_weight, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLargeTextField(controller: _bpCtrl, label: 'Blood Pressure', icon: Icons.favorite),
                const SizedBox(height: 16),
                _buildLargeTextField(controller: _symptomsCtrl, label: 'Symptoms', icon: Icons.sick, maxLines: 3),
                const SizedBox(height: 16),
                
                // Pregnancy Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text('Pregnant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    secondary: const Icon(Icons.pregnant_woman, size: 36, color: AppColors.primary),
                    value: _isPregnant,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isPregnant = val),
                  ),
                ),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    final patient = DatabaseService().generateNewPatient(
                      name: _nameCtrl.text,
                      age: int.tryParse(_ageCtrl.text) ?? 0,
                      weight: double.tryParse(_weightCtrl.text) ?? 0.0,
                      bp: _bpCtrl.text,
                      symptoms: _symptomsCtrl.text,
                      isPregnant: _isPregnant,
                    );
                    DatabaseService().addPatient(patient);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Patient saved to device!')),
                    );
                    Navigator.pop(context); // Save & exit
                  },
                  child: Text(AppStrings.save, style: const TextStyle(fontSize: 22)),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildLargeTextField({required TextEditingController controller, required String label, required IconData icon, bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(icon, size: 32, color: AppColors.primary),
        ),
      ),
    );
  }
}
