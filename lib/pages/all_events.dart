import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/detail_page.dart';
import 'package:event_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllEventsPage extends StatelessWidget {
  const AllEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Upcoming Events"),
        backgroundColor: Color(0xfff0f2ff),
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff0f2ff), Colors.white],
          ),
        ),
        child: StreamBuilder(
          stream: DatabaseMethods().getallEvents(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            List<DocumentSnapshot> allDocs =
                (snapshot.data.docs as List<DocumentSnapshot>).where((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null || data['Date'] == null || data['Date'] is! String) {
                return false;
              }
              final eventDate = DateTime.tryParse(data['Date']);
              if (eventDate == null) {
                return false;
              }
              final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
              return eventDateOnly.isAtSameMomentAs(today) || eventDateOnly.isAfter(today);
            }).toList();

            if (allDocs.isEmpty) {
              return Center(
                child: Text(
                  'No upcoming events found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(20.0),
              itemCount: allDocs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = allDocs[index];
                return _buildEventCard(ds, context);
              },
            );
          },
        ),
      ),
    );
  }

  // Copied from home_screen.dart for UI consistency
  Widget _buildEventCard(DocumentSnapshot ds, BuildContext context) {
    String formattedDate =
        DateFormat('MMM dd').format(DateTime.parse(ds["Date"]));
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPage(
                      image: ds["Image"],
                      name: ds["Name"],
                      location: ds["Location"],
                      date: ds["Date"],
                      detail: ds["Detail"],
                      price: ds["Price"],
                    )));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15.0)),
                  child: Image.network(
                    ds["Image"],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "assets/images/event.jpg",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                         Text(
                          formattedDate.split(' ')[0], // Month
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          formattedDate.split(' ')[1], // Day
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ds["Name"],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Colors.grey.shade600, size: 16),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          ds["Location"],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "\$${ds["Price"]}",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
