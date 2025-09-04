import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketEvent extends StatefulWidget {
  const TicketEvent({super.key});

  @override
  State<TicketEvent> createState() => _TicketEventState();
}

class _TicketEventState extends State<TicketEvent> {
  Stream? ticketStream;

  ontheload() async {
    ticketStream = await DatabaseMethods().getTickets();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    ontheload();
    super.initState();
  }

  Widget allTickets() {
    return StreamBuilder(
      stream: ticketStream,
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
                  bool hasPassed = currentDate.isAfter(parsedDate);
                  return hasPassed
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(
                            left: 5,
                            right: 20,
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(73, 0, 0, 0),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 20.0),
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.blue,
                                  ),

                                  Expanded(
                                    child: Text(
                                      ds["Location"],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      // textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10.0,
                                  bottom: 10.0,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(20),
                                      child: Image.network(
                                        ds["Image"],
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    SizedBox(width: 10.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ds["Event"],
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5.0),
                                              Expanded(
                                                child: Text(
                                                  ds["Date"],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5.0),
                                              Expanded(
                                                child: Text(
                                                  ds["Name"],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.group,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5.0),
                                              Text(
                                                ds["Number"],
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(width: 10.0),
                                              Icon(
                                                Icons.monetization_on,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 5.0),
                                              Expanded(
                                                child: Text(
                                                  "\$" + ds["Total"],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
        margin: EdgeInsets.only(left: 20.0, top: 40.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.arrow_back_ios_new_outlined),
                Spacer(),
                SizedBox(
                  // width: MediaQuery.of(context).size.width / 5.5,
                ),
                Text(
                  "Event Tickets",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 7, 119, 232),
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20.0),
            allTickets(),
          ],
        ),
      ),
    );
  }
}
