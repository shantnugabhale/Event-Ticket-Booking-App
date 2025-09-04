import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/admin/edit_subadmin.dart';
import 'package:flutter/material.dart';

class ManageSubadminsPage extends StatefulWidget {
  const ManageSubadminsPage({super.key});

  @override
  State<ManageSubadminsPage> createState() => _ManageSubadminsPageState();
}

class _ManageSubadminsPageState extends State<ManageSubadminsPage> {
  /// Deletes a specific admin document from Firestore.
  Future<void> _deleteAdmin(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Admin').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Admin deleted successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete admin: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage All Admins"),
        backgroundColor: Color(0xffe3e6ff),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the 'Admin' collection for real-time updates
        stream: FirebaseFirestore.instance.collection('Admin').snapshots(),
        builder: (context, snapshot) {
          // Show a loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Show an error message if something goes wrong
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }
          // Show a message if there are no admins
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No admins found.'));
          }

          // If data is available, display it in a list
          return ListView(
            padding: EdgeInsets.all(10.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              bool isMainAdmin = data['username'] == 'admin';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(
                    isMainAdmin ? Icons.shield : Icons.shield_sharp,
                    color: Colors.blue,
                    size: 40,
                  ),
                  title: Text(
                    data['username'] ?? 'No Username',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    isMainAdmin ? 'Role: Main Admin' : 'Role: Sub-Admin',
                    style: TextStyle(
                        color: isMainAdmin ? Colors.deepOrange.shade700 : null),
                  ),
                  // **CHANGE**: Updated logic to show different buttons based on role
                  trailing: isMainAdmin
                      ? // If it's the main admin, show ONLY the Edit button.
                      IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditSubadminPage(
                                  docId: document.id,
                                  currentUsername: data['username'],
                                  currentPassword: data['password'],
                                ),
                              ),
                            );
                          },
                        )
                      : // If it's a sub-admin, show BOTH Edit and Delete buttons.
                      Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit Button
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditSubadminPage(
                                      docId: document.id,
                                      currentUsername: data['username'],
                                      currentPassword: data['password'],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Delete Button
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                // Show a confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text(
                                          'Are you sure you want to delete this admin?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.red)),
                                          onPressed: () {
                                            _deleteAdmin(document.id);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

