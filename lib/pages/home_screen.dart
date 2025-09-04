import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/all_events.dart';
import 'package:event_app/pages/categories_event.dart';
import 'package:event_app/pages/detail_page.dart';
import 'package:event_app/services/database.dart';
import 'package:event_app/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// **CHANGE 1**: Added 'with AutomaticKeepAliveClientMixin<HomeScreen>'
class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  // **CHANGE 2**: Added this override to keep the state alive
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  Stream? eventStream;
  String? _currentCity;
  String? name;
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    _onScreenLoad();
    _searchController.addListener(() {
      setState(() {
        _searchActive = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onScreenLoad() async {
    await getthesharedpref();
    await _getCurrentCity();
    eventStream = DatabaseMethods().getallEvents();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getthesharedpref() async {
    name = await SharedPrefenceHelper().getUserName();
  }

  Future<void> _getCurrentCity() async {
    setState(() {
      _currentCity = "Fetching...";
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _currentCity = "Location Off");
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _currentCity = "Permission Denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _currentCity = "Permission Denied");
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _currentCity = placemarks.first.locality ?? "Unknown City";
        });
      }
    } catch (e) {
      setState(() => _currentCity = "Error");
    }
  }

  List<DocumentSnapshot> _performSearch(List<DocumentSnapshot> allDocs) {
    if (!_searchActive) {
      return allDocs;
    }
    String query = _searchController.text.toUpperCase();
    return allDocs.where((doc) {
      String eventName = doc['UpdatedName'] ?? '';
      return eventName.startsWith(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // **CHANGE 3**: Added 'super.build(context);' for the mixin to work
    super.build(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff0f2ff), Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildSearchBar(),
            if (!_searchActive) _buildSectionTitle("Explore by Category"),
            if (!_searchActive) _buildCategories(),
            _buildSectionTitle("Upcoming Events", showSeeAll: true),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 120.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20, bottom: 10),
        title: Text(
          "Find Events",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
        ),
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: Colors.blue.shade700),
                    SizedBox(width: 4.0),
                    Text(
                      _currentCity ?? "Loading...",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
               
                Text(
                  "Hello, ${name ?? 'User'}",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for events...',
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14.0),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionTitle(String title, {bool showSeeAll = false}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (showSeeAll)
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllEventsPage()));
                },
                child: Text(
                  "See All",
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategories() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 20.0),
          children: [
            _buildCategoryCard("Music", "assets/images/musical-note.png", Colors.red.shade100),
            _buildCategoryCard("Food", "assets/images/dish.png", Colors.green.shade100),
            _buildCategoryCard("Party", "assets/images/confetti.png", Colors.purple.shade100),
            _buildCategoryCard("Clothes", "assets/images/t-shirt.png", Colors.orange.shade100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String name, String imagePath, Color bgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoriesEvent(eventcategory: name)));
      },
      child: Container(
        width: 90,
        margin: EdgeInsets.only(right: 15.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 35, width: 35),
            SizedBox(height: 8.0),
            Text(
              name,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return StreamBuilder(
      stream: eventStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()));
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        List<DocumentSnapshot> allDocs =
            (snapshot.data.docs as List<DocumentSnapshot>).where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null ||
              data['Date'] == null ||
              data['Date'] is! String) {
            return false;
          }
          final eventDate = DateTime.tryParse(data['Date']);
          if (eventDate == null) {
            return false;
          }
          final eventDateOnly =
              DateTime(eventDate.year, eventDate.month, eventDate.day);
          return eventDateOnly.isAtSameMomentAs(today) ||
              eventDateOnly.isAfter(today);
        }).toList();

        final filteredDocs = _performSearch(allDocs);

        if (filteredDocs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                _searchActive ? 'No events found.' : 'No upcoming events.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // To show only a few items on the home screen
                if (index >= 4 && !_searchActive) return null; 
                DocumentSnapshot ds = filteredDocs[index];
                return _buildEventCard(ds);
              },
              childCount: _searchActive ? filteredDocs.length : (filteredDocs.length > 4 ? 4 : filteredDocs.length),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard(DocumentSnapshot ds) {
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
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
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

