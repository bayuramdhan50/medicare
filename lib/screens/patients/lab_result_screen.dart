import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/widgets/custom_button.dart';

class LabResultScreen extends StatelessWidget {
  final UserModel user;

  LabResultScreen({required this.user});

  // Method to fetch lab results from Firestore
  Future<List<Map<String, String>>> fetchLabResults() async {
    try {
      // Get the collection of lab results for the user
      final snapshot = await FirebaseFirestore.instance
          .collection(
              'lab_results') // Make sure this matches your Firestore structure
          .where('userId', isEqualTo: user.uid) // Assuming user has an id field
          .get();

      // Map the results into a list of maps, converting to Map<String, String>
      return snapshot.docs.map((doc) {
        return {
          'test': doc['test']?.toString() ?? '',
          'date': doc['date']?.toString() ?? '',
          'result': doc['result']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching lab results: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Results'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Lab Results for ${user.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Fetch lab results from Firestore
            FutureBuilder<List<Map<String, String>>>(
              future: fetchLabResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No lab results available.'));
                }

                final labResults = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: labResults.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                labResults[index]['test'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Date: ${labResults[index]['date']}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Result: ${labResults[index]['result']}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 16),
                              CustomButton(
                                text: 'View Details',
                                onPressed: () {
                                  // You can add logic to view detailed results or open a PDF here
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
