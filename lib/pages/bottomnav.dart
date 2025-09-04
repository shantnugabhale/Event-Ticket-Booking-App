import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:event_app/pages/booking.dart';
import 'package:event_app/pages/home_screen.dart';
import 'package:event_app/pages/profile.dart';
import 'package:flutter/material.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  late List<Widget> pages;
  late HomeScreen home;
  late Booking booking;
  late Profile profile;
  int currentTabIndex = 0;
  @override
  void initState() {
    home = HomeScreen();
    booking = Booking();
    profile = Profile();
    pages = [home, booking, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        items: [
          Icon(Icons.home_outlined,color: Colors.white, size: 30),
          Icon(Icons.book,color: Colors.white, size: 30),
          Icon(Icons.person_outline,color: Colors.white, size: 30),
        ],
        height: 65,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: Duration(microseconds: 500),
        onTap: (int index){
          setState(() {
            currentTabIndex = index;
          });
        },
      ),
      body: pages[currentTabIndex],
    );
  }
}
