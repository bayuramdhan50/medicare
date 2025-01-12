import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  final UserModel user;

  ManageUsersScreen({required this.user});

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color primaryColor = Color(0xFF08A8B1); // Tosca
  final Color secondaryColor = Color(0xFFF19E23); // Orange

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return Center(
              child: Text(
                'No users found.',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index];
              final userId = userData.id;
              final userName = userData['name'];
              final userEmail = userData['email'];
              final userRole = userData['role'] ?? 'patient';

              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: primaryColor,
                      ),
                    ),
                    title: Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: secondaryColor.withOpacity(0.5),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: userRole,
                            underline: SizedBox(),
                            isDense: true,
                            style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (String? newRole) {
                              if (newRole != null) {
                                _updateUserRole(userId, newRole);
                              }
                            },
                            items: ['patient', 'doctor', 'admin']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value.toUpperCase(),
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red.shade400,
                      ),
                      onPressed: () => _deleteUser(userId),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              "Confirm Deletion",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text("Are you sure you want to delete this user?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text("Delete"),
              ),
            ],
          );
        },
      );

      if (confirmDelete ?? false) {
        await _firestore.collection('users').doc(userId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: secondaryColor,
          ),
        );
      }
    } catch (e) {
      print("Error deleting user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': newRole});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to ${newRole.toUpperCase()}'),
          backgroundColor: secondaryColor,
        ),
      );
    } catch (e) {
      print("Error updating user role: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user role'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }
}
