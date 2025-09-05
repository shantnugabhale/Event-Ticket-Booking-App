import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
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

  String? name, image, id;

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  ontheload() async {
    name = await SharedPrefenceHelper().getUserName();
    image = await SharedPrefenceHelper().getUserImage();
    id = await SharedPrefenceHelper().getUserID();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // --- START IMAGE FIX ---
                CachedNetworkImage(
                  imageUrl: widget.image,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.2,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.2,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/images/event.jpg", // Fallback image
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.2,
                    fit: BoxFit.cover,
                  ),
                ),
                // --- END IMAGE FIX ---
                SizedBox(
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
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(left: 20.0, top: 40.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0, bottom: 8.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 10.0, color: Colors.black)],
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.date,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    widget.location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 20.0),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "About Event",
                style: TextStyle(
                  color: Color.fromARGB(255, 5, 2, 2),
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                widget.detail,
                style: const TextStyle(
                  color: Color.fromARGB(148, 0, 0, 0),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Number of Tickets ",
                    style: TextStyle(
                      color: Color.fromARGB(255, 5, 2, 2),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
                              setState(() {
                                ticket = ticket - 1;
                              });
                            }
                          },
                          child: const Text(
                            "-",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          ticket.toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 135, 246),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (ticket < 10) {
                              setState(() {
                                ticket = ticket + 1;
                              });
                            }
                          },
                          child: const Text(
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
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                children: [
                  Text(
                    "Amount : \$${(int.parse(widget.price) * ticket).toString()}",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 102, 47, 231),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
                    child: const Padding(
                      padding: EdgeInsets.only(
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
            const SizedBox(height: 10),
          ],
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
      await Stripe.instance.presentPaymentSheet().then((value) async {
        final int total = int.parse(widget.price) * ticket;
        Map<String, dynamic> bookingDetail = {
          "Number": ticket.toString(),
          "Total": total.toString(),
          "Event": widget.name,
          "Location": widget.location,
          "Date": widget.date,
          "Name": name,
          "Image": image,
          "EventImage": widget.image
        };

        if (id != null) {
          await DatabaseMethods().addUserBooking(bookingDetail, id!).then((value) async {
            await DatabaseMethods().addAdminTickets(bookingDetail, id!);
          });
        }
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text("Payment Successful"),
                  ],
                ),
              ],
            ),
          ),
        );
        paymentIntent = null;
      }).onError((error, StackTrace) {
        print("Error is :--> $error $StackTrace");
      });
    } on StripeException catch (e) {
      print("Error is --> $e");
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(content: Text("Cancelled")),
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