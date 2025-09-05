import 'package:event_app/admin/create_subadmin.dart';
import 'package:event_app/admin/manage_events.dart'; 
import 'package:event_app/admin/manage_subadmins.dart';
import 'package:event_app/admin/ticket_event.dart';
import 'package:event_app/admin/upload_event.dart';
import 'package:event_app/pages/signup.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final String docId;
  const AdminDashboard({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Color(0xffe3e6ff),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Logout'),
                    content: Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text('Logout', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Signup()),
                            (Route<dynamic> route) => false,
                          );
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
          ),
        ),
        child: GridView.count(
          crossAxisCount: 1, // A single column list
          padding: EdgeInsets.all(20.0), // Consistent padding
          mainAxisSpacing: 12, // Reduced vertical space between items
          // --- FIX: Controls the height of each item ---
          // A higher value makes the item shorter.
          childAspectRatio: (1 / .35), 
          children: <Widget>[
            makeDashboardItem("Upload Event", Icons.upload_file, 0, context),
            makeDashboardItem("Manage Events", Icons.edit_calendar, 1, context),
            makeDashboardItem("View Tickets", Icons.airplane_ticket_outlined, 2, context),
            makeDashboardItem("Create Subadmin", Icons.person_add_alt_1, 3, context),
            makeDashboardItem("Manage Admins", Icons.manage_accounts, 4, context),
          ],
        ),
      ),
    );
  }

  // --- FIX: Changed from a Column to a Row for a shorter, list-like item ---
  Widget makeDashboardItem(String title, IconData icon, int index, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UploadEvent()));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageEventsPage()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TicketEvent()));
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSubadminPage()));
            } else if (index == 4) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageSubadminsPage()));
            }
          },
          borderRadius: BorderRadius.circular(15.0),
          // Using a Row makes the item horizontal and more compact
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align content to the left
              children: <Widget>[
                Icon(
                  icon,
                  size: 35.0, // Slightly smaller icon
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: 25.0), // Space between icon and text
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0, // Larger font for better readability
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
