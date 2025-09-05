import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/admin/edit_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Deletes a specific event document from Firestore.
  Future<void> _deleteEvent(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Event').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Event deleted successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete event: ${e.toString()}'),
        ),
      );
    }
  }

  /// Builds a single filter chip.
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
            });
          }
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade800 : Colors.black87,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  /// Filters documents based on the selected criteria.
  List<DocumentSnapshot> _filterDocuments(List<DocumentSnapshot> docs) {
    List<DocumentSnapshot> filteredDocs = docs;

    // Filter by search query (event name)
    if (_searchQuery.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final name = doc['Name'] as String? ?? '';
        return name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by date
    if (_selectedFilter != 'All') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      filteredDocs = filteredDocs.where((doc) {
        try {
          final eventDate = DateTime.parse(doc['Date'] as String);
          switch (_selectedFilter) {
            case 'Today':
              return eventDate.year == today.year &&
                  eventDate.month == today.month &&
                  eventDate.day == today.day;
            case 'This Week':
              final startOfWeek = today.subtract(
                Duration(days: today.weekday - 1),
              );
              final endOfWeek = startOfWeek.add(const Duration(days: 6));
              return !eventDate.isBefore(startOfWeek) &&
                  !eventDate.isAfter(endOfWeek);
            case 'This Month':
              return eventDate.year == today.year &&
                  eventDate.month == today.month;
            case 'This Year':
              return eventDate.year == today.year;
            default:
              return true;
          }
        } catch (e) {
          // If date parsing fails, exclude the item
          return false;
        }
      }).toList();
    }

    return filteredDocs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Events"),
        backgroundColor: const Color(0xffe3e6ff),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by event name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Today'),
                _buildFilterChip('This Week'),
                _buildFilterChip('This Month'),
                _buildFilterChip('This Year'),
              ],
            ),
          ),
          // Event List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Event')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong!'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No events found.'));
                }

                final filteredDocs = _filterDocuments(snapshot.data!.docs);

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('No events match your criteria.'),
                  );
                }

                return ListView(
                  // --- THIS IS THE CRITICAL FIX ---
                  cacheExtent: 9999,
                  // ---------------------------------
                  padding: const EdgeInsets.all(10.0),
                  children: filteredDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    DateTime? eventDate;
                    try {
                      eventDate = DateTime.parse(data['Date']);
                    } catch (e) {
                      // Handle cases with invalid date format gracefully
                      return const SizedBox.shrink(); // Don't display the card
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              // --- START CHANGE ---
                              child: CachedNetworkImage(
                                imageUrl:
                                    data['Image'] ??
                                    'https://via.placeholder.com/150',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.event,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              // --- END CHANGE ---
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['Name'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['Location'] ?? 'No Location',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${DateFormat('MMM dd, yyyy').format(eventDate!)} at ${data['Time']}",
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Action buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue.shade700,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditEventPage(
                                          docId: document.id,
                                          eventData: data,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text(
                                            'Are you sure you want to delete this event?',
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onPressed: () {
                                                _deleteEvent(document.id);
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
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
