import 'package:event_app/admin/ticket_event.dart';
import 'package:event_app/admin/upload_event.dart';
import 'package:event_app/pages/signup.dart';
import 'package:flutter/material.dart';

class SubadminDashboard extends StatelessWidget {
  const SubadminDashboard({super.key, required String docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sub-Admin Dashboard"),
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
          crossAxisCount: 1,
          padding: EdgeInsets.all(20.0),
          mainAxisSpacing: 12,
          childAspectRatio: (1 / .35),
          children: <Widget>[
            makeDashboardItem("Upload Event", Icons.upload_file, 0, context),
            makeDashboardItem("View Tickets", Icons.airplane_ticket_outlined, 1, context),
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
            }
          },
          borderRadius: BorderRadius.circular(15.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  icon,
                  size: 35.0,
                  color: Colors.blue.shade700,
                ),
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

