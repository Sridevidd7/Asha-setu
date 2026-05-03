import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:asha_setu/core/utils/constants.dart';
import 'package:asha_setu/core/services/database_service.dart';
import 'package:asha_setu/core/models/patient_model.dart';
import 'package:asha_setu/core/models/vaccination_model.dart';

class VaccinationTrackerScreen extends StatefulWidget {
  const VaccinationTrackerScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationTrackerScreen> createState() => _VaccinationTrackerScreenState();
}

class _VaccinationTrackerScreenState extends State<VaccinationTrackerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.vaccinationTracker),
        backgroundColor: AppColors.success,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                defaultTextStyle: TextStyle(fontSize: 18),
                weekendTextStyle: TextStyle(fontSize: 18, color: Colors.red),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assigned Vaccinations',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: DatabaseService().vaccinationsBox.listenable(),
              builder: (context, box, _) {
                final allVacs = DatabaseService().getVaccinations();
                // We're sorting them: chronological
                allVacs.sort((a, b) => a.date.compareTo(b.date));

                if (allVacs.isEmpty) {
                  return const Center(child: Text('No vaccinations assigned.', style: TextStyle(fontSize: 18)));
                }

                // Optimization: Pre-fetch patients into a map for fast lookup
                final pMap = { for (var p in DatabaseService().getPatients()) p.id: p };

                return ListView.builder(
                  itemCount: allVacs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final vac = allVacs[index];
                    final patient = pMap[vac.patientId];
                    if (patient == null) return const SizedBox.shrink(); // Orphan edge-case

                    // Evaluate status
                    final msNow = DateTime.now().millisecondsSinceEpoch;
                    bool isMissed = !vac.isCompleted && vac.date < msNow;
                    bool isPending = !vac.isCompleted && vac.date >= msNow;

                    Color statusColor = AppColors.success;
                    String statusText = 'Completed';
                    if (isMissed) {
                      statusColor = AppColors.alert;
                      statusText = 'Missed';
                    } else if (isPending) {
                      statusColor = AppColors.warning;
                      statusText = 'Pending';
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: statusColor, width: 2),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.2),
                          child: Icon(Icons.vaccines, color: statusColor, size: 28),
                        ),
                        title: Text(
                          vac.vaccineName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Patient: ${patient.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(vac.date).toString().split(' ')[0], 
                              style: const TextStyle(fontSize: 14)
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () {
                          if (!vac.isCompleted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Update Vaccination'),
                                content: Text('Mark ${vac.vaccineName} as Completed for ${patient.name}?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                    onPressed: () {
                                      final updatedVac = Vaccination(
                                        id: vac.id,
                                        patientId: vac.patientId,
                                        vaccineName: vac.vaccineName,
                                        date: vac.date,
                                        isCompleted: true,
                                        lastUpdated: DateTime.now().millisecondsSinceEpoch,
                                      );
                                      DatabaseService().updateVaccination(updatedVac);
                                      Navigator.pop(context);
                                    }, 
                                    child: const Text('Mark Completed')
                                  ),
                                ],
                              )
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open a simple dialog to assign a manual vaccine to the FIRST patient in the DB for prototyping.
          final patients = DatabaseService().getPatients();
          if (patients.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a patient first!')));
            return;
          }
          final newVac = Vaccination(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            patientId: patients.first.id,
            vaccineName: 'Polio Drop',
            date: DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
            isCompleted: false,
            lastUpdated: DateTime.now().millisecondsSinceEpoch,
          );
          DatabaseService().addVaccination(newVac);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock vaccine assigned to first patient.')));
        },
        backgroundColor: AppColors.success,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
