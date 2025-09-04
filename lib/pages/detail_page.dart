import 'dart:convert';

import 'package:event_app/services/data.dart';
import 'package:event_app/services/database.dart';
import 'package:event_app/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class DetailPage extends StatefulWidget {
  final String image, name, location, date, detail, price;
  const DetailPage({
    Key? key,
    required this.image,
    required this.name,
    required this.location,
    required this.date,
    required this.detail,
    required this.price,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int ticket = 1;


  String? name ,image , id ;

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  ontheload() async{
    name = await SharedPrefenceHelper().getUserName();
    image = await SharedPrefenceHelper().getUserImage();
    id = await SharedPrefenceHelper().getUserID();

    setState(() {
      
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    "assets/images/event.jpg",
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.2,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(left: 20.0, top: 40.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(color: Colors.black45),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: const Color.fromARGB(
                                      210,
                                      255,
                                      255,
                                      255,
                                    ),
                                    size: 20,
                                  ),
                                  Text(
                                    widget.date,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Text(
                                      widget.location,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "About Event",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 5, 2, 2),
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  widget.detail,
                  style: TextStyle(
                    color: const Color.fromARGB(148, 0, 0, 0),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 50),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Number of Tickets ",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 5, 2, 2),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 110,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (ticket > 1) {
                                ticket = ticket - 1;
                                setState(() {});
                              }
                            },
                            child: Text(
                              "-",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            ticket.toString(),
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 135, 246),
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              if (ticket < 10) {
                                ticket = ticket + 1;
                                setState(() {});
                              }
                            },
                            child: Text(
                              "+",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.0),

              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  children: [
                    Text(
                      "Amount : \$${(int.parse(widget.price) * ticket).toString()}",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 102, 47, 231),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        makepayment(
                          (int.parse(widget.price) * ticket).toString(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          "Book Now",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? paymentIntent;

  Future<void> makepayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.dark,
              merchantDisplayName: 'Admin',
            ),
          )
          .then((value) {});

      displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception: $e$s');
    }
  }

  void displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance
          .presentPaymentSheet()
          .then((value) async {
            final int total = int.parse(widget.price) * ticket;
            Map<String, dynamic> Bookingdetail = {
              "Number" : ticket.toString(),
              "Total" : total.toString(),
              "Event" : widget.name,
              "Location" : widget.location,
              "Date" : widget.date,
              "Name" : name,
              "Image" :image,
              "EventImage" : widget.image
            };
           
          if(id != null){
            await DatabaseMethods().addUserBooking(Bookingdetail,id!).then((value) async {
              await DatabaseMethods().addAdminTickets(Bookingdetail, id!);
            });
          }
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        Text("Payment Successfull"),
                      ],
                    ),
                  ],
                ),
              ),
            );
            paymentIntent = null;
          })
          .onError((error, StackTrace) {
            print("Error is :--> $error $StackTrace");
          });
    } on StripeException catch (e) {
      print("Error is --> $e");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text("Cancelled")),
      );
    } catch (e) {
      print('$e');
    }
  }

  Future createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secrekey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Stripe error ${response.statusCode}: ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user : ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount) * 100);
    return calculatedAmount.toString();
  }
}
