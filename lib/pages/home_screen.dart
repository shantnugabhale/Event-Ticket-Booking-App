import 'package:cloud_firestore/cloud_firestore.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  var tempSearchStore = [];
  TextEditingController searchcontroller = TextEditingController();
  Stream? eventStream;
  String? _currentCity;
  String? name; // User's name
  bool search = false;

  @override
  void initState() {
    super.initState();
    // **FIX 1: Call an async function from initState without making initState async**
    _onScreenLoad();
  }

  /// Handles all asynchronous setup when the screen loads.
  void _onScreenLoad() async {
    await getthesharedpref();
    await _getCurrentCity();
    eventStream = DatabaseMethods().getallEvents();
    if (mounted) { // Check if the widget is still in the tree
      setState(() {});
    }
  }

  /// Fetches the user's name from shared preferences.
  Future<void> getthesharedpref() async {
    name = await SharedPrefenceHelper().getUserName();
  }

  /// Fetches the user's current city and handles location permissions.
  Future<void> _getCurrentCity() async {
    setState(() {
      _currentCity = "Fetching location...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentCity = "Location services are disabled.";
        });
        return;
      }
      
      LocationPermission permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _currentCity = "Permission Denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          _currentCity = placemarks.first.locality ?? "Unknown City";
        });
      } else {
        setState(() {
          _currentCity = "City not found";
        });
      }
    } catch (e) {
      setState(() {
        _currentCity = "Error fetching location";
      });
    }
  }

  /// Performs a case-insensitive search on the list of events.
  void performSearch(String value, List<DocumentSnapshot> allDocs) {
    if (value.isEmpty) {
      setState(() {
        search = false;
        tempSearchStore = [];
      });
      return;
    }

    setState(() {
      search = true;
      tempSearchStore = [];
    });

    String searchQuery = value.toUpperCase();

    for (var doc in allDocs) {
      String eventName = doc['UpdatedName'] ?? '';
      if (eventName.startsWith(searchQuery)) {
        tempSearchStore.add(doc.data());
      }
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 20.0, top: 50.0, right: 0.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
          ),
        ),
        child: StreamBuilder(
          stream: eventStream,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            List<DocumentSnapshot> allDocs = snapshot.data.docs;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: const Color.fromARGB(195, 11, 3, 3), size: 22.0),
                      SizedBox(width: 5.0),
                      Text(
                        _currentCity ?? "Loading location...",
                        style: TextStyle(
                            color: const Color.fromARGB(200, 29, 7, 7),
                            fontSize: 20.0),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  // **FIX 2: Safely display the name with a fallback**
                  Text(
                    "Hello, ${name ?? 'User'}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "There are ${allDocs.length} events\n around your location",
                    style: TextStyle(
                        color: Color(0xff6351ec),
                        fontSize: 25.0,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    padding: EdgeInsets.only(left: 20.0),
                    margin: EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchcontroller,
                      onChanged: (value) {
                        performSearch(value, allDocs);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search_outlined),
                        hintText: "Search an Event",
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  search
                      ? ListView(
                          padding: EdgeInsets.zero,
                          primary: false,
                          shrinkWrap: true,
                          children: tempSearchStore.map((element) {
                            return buildResultCard(element);
                          }).toList(),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 90.0,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  buildCategory("Music", "assets/images/musical-note.png"),
                                  buildCategory("Food", "assets/images/dish.png"),
                                  buildCategory("Party", "assets/images/confetti.png"),
                                  buildCategory("Clothes", "assets/images/t-shirt.png"),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Upcoming Events",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "See All",
                                    style: TextStyle(
                                      color: Color(0xff6351ec),
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.0),
                            allEvent(allDocs),
                          ],
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  // All other widgets (allEvent, buildCategory, buildResultCard) remain the same
  // ...
  Widget allEvent(List<DocumentSnapshot> docs) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: docs.length,
      itemBuilder: (context, index) {
        DocumentSnapshot ds = docs[index];
        String inputDate = ds["Date"];
        DateTime parsedDate = DateTime.parse(inputDate);
        String formattedDate = DateFormat('MMM\ndd').format(parsedDate);
        DateTime currentDate = DateTime.now();
        bool hasPassed = currentDate.isAfter(parsedDate);

        return hasPassed
            ? Container()
            : GestureDetector(
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
                  margin: EdgeInsets.only(bottom: 20.0, right: 20.0),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                ds["Image"],
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/images/event.jpg",
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(1),
                              width: 60.0,
                              height: 50.0,
                              margin: EdgeInsets.only(left: 5.0, top: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Text(
                                  formattedDate,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ds["Name"],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$" + ds["Price"],
                              style: TextStyle(
                                color: Color(0xff6351ec),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Colors.grey),
                          SizedBox(width: 5.0),
                          Text(
                            ds["Location"],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
   Widget buildCategory(String name, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoriesEvent(eventcategory: name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            width: 90,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, height: 40, width: 40),
                SizedBox(height: 5.0),
                Text(
                  name,
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
   Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              image: data["Image"],
              name: data["Name"],
              location: data["Location"],
              date: data["Date"],
              detail: data["Detail"],
              price: data["Price"],
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  data['Image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.event, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 15.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['Name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "\$" + data["Price"],
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.0),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}