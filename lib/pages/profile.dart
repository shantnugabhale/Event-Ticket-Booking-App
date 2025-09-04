import 'package:event_app/pages/signup.dart';
import 'package:event_app/services/auth.dart';
import 'package:event_app/services/shared_pref.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? image, name, email, id;

  getthesharedpref() async {
    id = await SharedPrefenceHelper().getUserID();
    image = await SharedPrefenceHelper().getUserImage();
    name = await SharedPrefenceHelper().getUserName();
    email = await SharedPrefenceHelper().getUserEmail();

    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: image == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                // left: 20.0,
                top: 50.0,
                // right: 20.0,
                bottom: 10.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                      child: Column(
                        children: [
                          SizedBox(height: 20.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: Image.network(
                              image!,
                              height: 120,
                              width: 120,

                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          Container(
                            padding: EdgeInsets.only(
                              left: 10.0,
                              top: 10.0,
                              bottom: 10.0,
                            ),
                            margin: EdgeInsets.only(left: 15.0, right: 15.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Name",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          118,
                                          0,
                                          0,
                                          0,
                                        ),
                                      ),
                                    ),
                                    Text(name!),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Container(
                            padding: EdgeInsets.only(
                              left: 10.0,
                              top: 10.0,
                              bottom: 10.0,
                            ),
                            margin: EdgeInsets.only(left: 15.0, right: 15.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Email",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          118,
                                          0,
                                          0,
                                          0,
                                        ),
                                      ),
                                    ),
                                    Text(email!),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Container(
                            padding: EdgeInsets.only(
                              left: 10.0,
                              top: 10.0,
                              bottom: 10.0,
                            ),
                            margin: EdgeInsets.only(left: 15.0, right: 15.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.contact_emergency,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Contact Us",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          0,
                                          0,
                                          0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15.0),
                          GestureDetector(
                            onTap: () {
                              AuthMethods().SignOut().then((value) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Signup(),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 10.0,
                                top: 10.0,
                                bottom: 10.0,
                              ),
                              margin: EdgeInsets.only(left: 15.0, right: 15.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "LogOut",
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            0,
                                            0,
                                            0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15.0),
                          GestureDetector(
                            onTap: () {
                              AuthMethods().deleteuser().then(
                                (value) => {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Signup(),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 10.0,
                                top: 10.0,
                                bottom: 10.0,
                              ),
                              margin: EdgeInsets.only(left: 15.0, right: 15.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Delete Account",
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            0,
                                            0,
                                            0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
