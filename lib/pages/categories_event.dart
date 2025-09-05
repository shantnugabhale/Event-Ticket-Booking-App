import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/detail_page.dart';
import 'package:event_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enums to manage filter and sort states
enum FilterOption { All, Today, Week, Month }
enum SortOption { None, PriceLowToHigh, PriceHighToLow }

class CategoriesEvent extends StatefulWidget {
  final String eventcategory;
  const CategoriesEvent({super.key, required this.eventcategory});

  @override
  State<CategoriesEvent> createState() => _CategoriesEventState();
}

class _CategoriesEventState extends State<CategoriesEvent> {
  Stream? eventStream;
  FilterOption _selectedFilter = FilterOption.All;
  SortOption _selectedSort = SortOption.None;

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  getontheload() {
    // We get the stream directly, no need for async/await here
    eventStream = DatabaseMethods().getEventCategories(widget.eventcategory);
    setState(() {});
  }

  /// Applies date filters and price sorting to the list of events.
  List<DocumentSnapshot> _applyFiltersAndSort(List<DocumentSnapshot> allEvents) {
    List<DocumentSnapshot> filteredList = List.from(allEvents);
    final now = DateTime.now();

    // 1. Apply Date Filter
    if (_selectedFilter != FilterOption.All) {
      filteredList = filteredList.where((event) {
        final docDate = DateTime.tryParse(event['Date'] ?? '');
        if (docDate == null) return false;

        switch (_selectedFilter) {
          case FilterOption.Today:
            return docDate.year == now.year && docDate.month == now.month && docDate.day == now.day;
          case FilterOption.Week:
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final endOfWeek = startOfWeek.add(const Duration(days: 7));
            return docDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && docDate.isBefore(endOfWeek);
          case FilterOption.Month:
            return docDate.year == now.year && docDate.month == now.month;
          default:
            return true;
        }
      }).toList();
    }

    // 2. Apply Price Sort
    if (_selectedSort != SortOption.None) {
      filteredList.sort((a, b) {
        final priceA = double.tryParse(a['Price'] ?? '0') ?? 0;
        final priceB = double.tryParse(b['Price'] ?? '0') ?? 0;
        if (_selectedSort == SortOption.PriceLowToHigh) {
          return priceA.compareTo(priceB);
        } else {
          return priceB.compareTo(priceA);
        }
      });
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff0f2ff), Colors.white],
          ),
        ),
        child: CustomScrollView(
          // --- ADD THIS LINE ---
          cacheExtent: 9999,
          // ---------------------
          slivers: [
            _buildAppBar(),
            _buildFilterBar(),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      title: Text(widget.eventcategory, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  SliverToBoxAdapter _buildFilterBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(FilterOption.All, "All"),
                    _buildFilterChip(FilterOption.Today, "Today"),
                    _buildFilterChip(FilterOption.Week, "This Week"),
                    _buildFilterChip(FilterOption.Month, "This Month"),
                  ],
                ),
              ),
            ),
            PopupMenuButton<SortOption>(
              onSelected: (sort) => setState(() => _selectedSort = sort),
              icon: Icon(Icons.sort, color: Colors.blue.shade800),
              itemBuilder: (context) => [
                const PopupMenuItem(value: SortOption.PriceLowToHigh, child: Text("Price: Low to High")),
                const PopupMenuItem(value: SortOption.PriceHighToLow, child: Text("Price: High to Low")),
              ],
            ),
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
        onSelected: (selected) => setState(() => _selectedFilter = option),
        selectedColor: Colors.blueAccent.withOpacity(0.8),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildEventList() {
    return StreamBuilder(
      stream: eventStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }

        final allDocs = (snapshot.data.docs as List<DocumentSnapshot>)
            .where((doc) => !DateTime.now().isAfter(DateTime.parse(doc["Date"])))
            .toList();

        final filteredDocs = _applyFiltersAndSort(allDocs);

        if (filteredDocs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'No events match your filter.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                DocumentSnapshot ds = filteredDocs[index];
                return _buildEventCard(ds);
              },
              childCount: filteredDocs.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard(DocumentSnapshot ds) {
    String formattedDate = DateFormat('MMM dd').format(DateTime.parse(ds["Date"]));

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
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                  // --- START CHANGE ---
                  child: CachedNetworkImage(
                    imageUrl: ds["Image"],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/images/event.jpg",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // --- END CHANGE ---
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          formattedDate.split(' ')[0], // Month
                          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          formattedDate.split(' ')[1], // Day
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
                    style: const TextStyle(color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          ds["Location"],
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "\$${ds["Price"]}",
                        style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 20),
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