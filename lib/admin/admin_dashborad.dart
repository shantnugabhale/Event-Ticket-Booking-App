import 'package:event_app/admin/create_subadmin.dart';
import 'package:event_app/admin/manage_subadmins.dart';
import 'package:event_app/admin/ticket_event.dart';
import 'package:event_app/admin/upload_event.dart';
import 'package:event_app/pages/signup.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
          // **CHANGE**: Set to 1 for a single-column list view
          crossAxisCount: 1,
          padding: EdgeInsets.all(20.0),
          crossAxisSpacing: 15,
          // **CHANGE**: Reduced vertical spacing between items
          mainAxisSpacing: 12,
          // **CHANGE**: Adjust aspect ratio to control item height in a single column
          childAspectRatio: (1 / .35), // Width-to-height ratio; higher value = shorter item
          children: <Widget>[
            makeDashboardItem("Upload Event", Icons.upload_file, 0, context),
            makeDashboardItem("View Tickets", Icons.airplane_ticket_outlined, 1, context),
            makeDashboardItem("Create Subadmin", Icons.person_add_alt_1, 2, context),
            makeDashboardItem("Manage Admins", Icons.manage_accounts, 3, context),
          ],
        ),
      ),
    );
  }

  /// Creates a reusable and styled card widget for each dashboard item.
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => TicketEvent()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSubadminPage()));
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageSubadminsPage()));
            }
          },
          borderRadius: BorderRadius.circular(15.0),
          // **CHANGE**: Using a Row for a more compact, horizontal layout inside the card
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  icon,
                  // **CHANGE**: Reduced icon size
                  size: 35.0,
                  color: Colors.blue.shade700,
                ),
                // **CHANGE**: Reduced spacing between icon and text
                SizedBox(width: 25.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
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

