import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/detail_page.dart';
import 'package:event_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoriesEvent extends StatefulWidget {
  final String eventcategory;
  CategoriesEvent({required this.eventcategory});
  @override
  State<CategoriesEvent> createState() => _CategoriesEventState();
}

class _CategoriesEventState extends State<CategoriesEvent> {
  Stream? eventStream;

  getontheload() async {
    eventStream = await DatabaseMethods().getEventCategories(
      widget.eventcategory,
    );
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getontheload();
    super.initState();
  }

  Widget allEvent() {
    return StreamBuilder(
      stream: eventStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  String inputDate = ds["Date"];
                  DateTime parsedDate = DateTime.parse(inputDate);
                  String formattedDate = DateFormat(
                    'MMM,dd',
                  ).format(parsedDate);
                  DateTime currentDate = DateTime.now();
                  // Only compare dates, not time
                  DateTime currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
                  DateTime parsedDateOnly = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
                  bool hasPassed = currentDateOnly.isAfter(parsedDateOnly);
                  
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
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(right: 20.0,left: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.asset(
                                        "assets/images/event.jpg",
                                        height: 200,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      width: 50.0,
                                      margin: EdgeInsets.only(
                                        left: 10.0,
                                        top: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
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
                              SizedBox(height: 5.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      ds["Name"],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0,left: 20.0),
                                    child: Text(
                                      "\$" + ds["Price"],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xff6351ec),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: const Color.fromARGB(195, 11, 3, 3),
                                      // size: 20.0,
                                    ),
                                    Text(
                                      ds["Location"],
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          200,
                                          29,
                                          7,
                                          7,
                                        ),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                },
              )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 50.0, bottom: 20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new_rounded),
                ),
                Spacer(),
                Text(
                  widget.eventcategory,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: const Color.fromARGB(255, 249, 249, 249),
                ),
                child: Column(children: [SizedBox(height: 30.0), allEvent()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
