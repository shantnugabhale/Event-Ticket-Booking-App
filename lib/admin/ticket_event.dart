import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enum to manage filter states
enum FilterOption { All, Today, Week, Month }

class TicketEvent extends StatefulWidget {
  const TicketEvent({super.key});

  @override
  State<TicketEvent> createState() => _TicketEventState();
}

class _TicketEventState extends State<TicketEvent> {
  Stream? ticketStream;
  FilterOption _selectedFilter = FilterOption.All;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // **FIX**: Assign the stream directly without async/await.
    ticketStream = DatabaseMethods().getTickets();
    // Re-filter the list whenever the search text changes
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Applies date and search filters to the list of all tickets.
  List<DocumentSnapshot> _applyFilters(List<DocumentSnapshot> allTickets) {
    List<DocumentSnapshot> filteredList = List.from(allTickets);
    final now = DateTime.now();

    // 1. Apply Date Filter based on the selected chip
    if (_selectedFilter != FilterOption.All) {
      filteredList = filteredList.where((ticket) {
        final docDate = DateTime.parse(ticket['Date']);
        switch (_selectedFilter) {
          case FilterOption.Today:
            return docDate.year == now.year &&
                docDate.month == now.month &&
                docDate.day == now.day;
          case FilterOption.Week:
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final endOfWeek = startOfWeek.add(Duration(days: 7));
            return docDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                docDate.isBefore(endOfWeek);
          case FilterOption.Month:
            return docDate.year == now.year && docDate.month == now.month;
          default:
            return true;
        }
      }).toList();
    }

    // 2. Apply Search Filter based on the text input
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredList = filteredList.where((ticket) {
        final eventName = (ticket['Event'] as String? ?? '').toLowerCase();
        return eventName.contains(query);
      }).toList();
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Tickets"),
        backgroundColor: Color(0xffe3e6ff),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Search Bar UI
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by event name...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Filter Chips UI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip(FilterOption.All, "All"),
                    _buildFilterChip(FilterOption.Today, "Today"),
                    _buildFilterChip(FilterOption.Week, "This Week"),
                    _buildFilterChip(FilterOption.Month, "This Month"),
                  ],
                ),
              ),
            ),
            // Ticket List UI
            Expanded(child: allTickets()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(FilterOption option, String label) {
    bool isSelected = _selectedFilter == option;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = option;
          });
        },
        selectedColor: Colors.blueAccent.withOpacity(0.8),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget allTickets() {
    return StreamBuilder(
      stream: ticketStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong!'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tickets found.'));
        }

        final allDocs = snapshot.data!.docs as List<DocumentSnapshot>;
        final filteredDocs = _applyFilters(allDocs);

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              'No tickets match your filter.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = filteredDocs[index];
            DateTime parsedDate = DateTime.parse(ds["Date"]);
            
            return Card(
              elevation: 5,
              margin: EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ds["Event"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: Colors.grey.shade600, size: 16),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    ds["Location"],
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Divider(height: 12),
                            Row(
                              children: [
                                // **FIX**: Added a fallback for the user image
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: (ds["Image"] != null && ds["Image"].isNotEmpty)
                                      ? NetworkImage(ds["Image"])
                                      : null,
                                  child: (ds["Image"] == null || ds["Image"].isEmpty)
                                      ? Icon(Icons.person, size: 20, color: Colors.grey.shade500)
                                      : null,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ds["Name"],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 110,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatRow(Icons.calendar_today,
                              DateFormat('MMM dd').format(parsedDate)),
                          SizedBox(height: 8),
                          _buildStatRow(
                              Icons.group, "${ds["Number"]} Tickets"),
                          SizedBox(height: 8),
                          _buildStatRow(Icons.monetization_on,
                              "\$${ds["Total"]}",
                              color: Colors.green.shade700),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey.shade700, size: 16),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color ?? Colors.black87,
                fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

