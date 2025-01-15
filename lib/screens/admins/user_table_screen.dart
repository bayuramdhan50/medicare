import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';

class UserTableScreen extends StatefulWidget {
  @override
  _UserTableScreenState createState() => _UserTableScreenState();
}

class _UserTableScreenState extends State<UserTableScreen> {
  String selectedRole = 'all';
  final Color primaryColor = Color(0xFF08A8B1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabel Pengguna', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(
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
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRole,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                        items: [
                          DropdownMenuItem(
                              value: 'all', child: Text('Semua Role')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(
                              value: 'doctor', child: Text('Doctor')),
                          DropdownMenuItem(
                              value: 'patient', child: Text('Patient')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedRole == 'all'
                    ? FirebaseFirestore.instance.collection('users').snapshots()
                    : FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: selectedRole)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Terjadi kesalahan'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    );
                  }

                  return Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 600,
                        headingRowColor: MaterialStateProperty.all(
                          primaryColor.withOpacity(0.1),
                        ),
                        columns: [
                          DataColumn2(
                            label: Text(
                              'Nama',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            size: ColumnSize.L,
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Role',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn2(
                            label: Text(
                              'Detail',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            size: ColumnSize.S,
                          ),
                        ],
                        rows: snapshot.data!.docs.map((doc) {
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;
                          return DataRow(
                            cells: [
                              DataCell(Text(data['name'] ?? '-')),
                              DataCell(Text(data['email'] ?? '-')),
                              DataCell(_buildRoleChip(data['role'])),
                              DataCell(
                                IconButton(
                                  icon: Icon(
                                    Icons.info_outline,
                                    color: primaryColor,
                                  ),
                                  onPressed: () {
                                    _showUserDetails(context, data);
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String? role) {
    Color chipColor;
    switch (role) {
      case 'admin':
        chipColor = Colors.red;
        break;
      case 'doctor':
        chipColor = Colors.blue;
        break;
      case 'patient':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Text(
        role ?? '-',
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.person, color: primaryColor),
            SizedBox(width: 8),
            Text('Detail Pengguna'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nama', userData['name']),
              _buildDetailRow('Email', userData['email']),
              _buildDetailRow('Role', userData['role']),
              _buildDetailRow('UID', userData['uid']),
              if (userData['role'] == 'patient') ...[
                Divider(height: 24),
                Text(
                  'Informasi Pasien',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                _buildDetailRow('Umur', userData['age']?.toString()),
                _buildDetailRow('Gender', userData['gender']),
                _buildDetailRow('Status Kesehatan', userData['healthStatus']),
              ],
              if (userData['fcmToken'] != null) ...[
                Divider(height: 24),
                _buildDetailRow('FCM Token', userData['fcmToken']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
