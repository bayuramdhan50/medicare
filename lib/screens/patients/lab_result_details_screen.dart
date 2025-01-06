import 'package:flutter/material.dart';

class LabResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic> labResult;

  LabResultDetailScreen({required this.labResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lab Result Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test: ${labResult['test']}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Date: ${labResult['date']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Result: ${labResult['result']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${labResult['status'] ?? 'Pending'}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            SizedBox(height: 20),
            Text(
              'Doctor Notes:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(labResult['notes'] ?? 'No additional notes.',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
