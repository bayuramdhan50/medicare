import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medicare/models/user_model.dart';

class UserStatisticsScreen extends StatefulWidget {
  final UserModel user;

  const UserStatisticsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserStatisticsScreen> createState() => _UserStatisticsScreenState();
}

class _UserStatisticsScreenState extends State<UserStatisticsScreen> {
  final Color primaryColor = Color(0xFF08A8B1); // Tosca
  final Color secondaryColor = Color(0xFFF19E23); // Orange
  Map<String, int> doctorPatientCount = {};
  Map<String, String> doctorNames = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctorPatientCount();
  }

  Future<void> fetchDoctorPatientCount() async {
    setState(() => isLoading = true);

    try {
      print('=== CHECKING ALL APPOINTMENTS ===');

      // Ambil semua appointments (tanpa filter status)
      QuerySnapshot allAppointments =
          await FirebaseFirestore.instance.collection('appointments').get();

      print('\nTotal semua appointments: ${allAppointments.docs.length}');
      print('\nDetail setiap appointment:');
      allAppointments.docs.forEach((doc) {
        print('''
        ID: ${doc.id}
        Doctor: ${doc['doctor']}
        DoctorUID: ${doc['doctorUid']}
        Status: ${doc['status']}
        ''');
      });

      // Ambil semua dokter terlebih dahulu
      QuerySnapshot doctorsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      print('Jumlah total dokter: ${doctorsSnapshot.docs.length}');
      doctorsSnapshot.docs.forEach((doc) {
        doctorPatientCount[doc.id] = 0;
        doctorNames[doc.id] = doc['name'];
        print('Dokter: ${doc['name']}, ID: ${doc.id}');
      });

      // Hitung semua appointments per dokter (tanpa filter status)
      for (var doc in allAppointments.docs) {
        String doctorId = doc['doctorUid'];
        String doctorName = doc['doctor'];
        doctorNames[doctorId] = doctorName;
        print('Appointment untuk dokter: $doctorName (ID: $doctorId)');
        doctorPatientCount[doctorId] = (doctorPatientCount[doctorId] ?? 0) + 1;
      }

      // Print hasil akhir
      doctorPatientCount.forEach((doctorId, count) {
        print('Dokter ${doctorNames[doctorId]} memiliki $count pasien');
      });

      setState(() => isLoading = false);
    } catch (e) {
      print('Error checking appointments: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            : Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Statistik Pasien per Dokter',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total Pasien: ${doctorPatientCount.values.fold(0, (a, b) => a + b)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: doctorPatientCount.values.isEmpty
                              ? 10
                              : doctorPatientCount.values
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble() +
                                  2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              tooltipBorder: BorderSide(color: primaryColor),
                              tooltipPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              tooltipMargin: 8,
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()} Pasien',
                                  TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  final doctorId =
                                      doctorPatientCount.keys.elementAt(index);
                                  final doctorName = doctorNames[doctorId] ??
                                      'Dr.${index + 1}';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      doctorName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: doctorPatientCount.entries
                              .map((entry) => BarChartGroupData(
                                    x: doctorPatientCount.keys
                                        .toList()
                                        .indexOf(entry.key),
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value.toDouble(),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            primaryColor,
                                            secondaryColor,
                                          ],
                                        ),
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
