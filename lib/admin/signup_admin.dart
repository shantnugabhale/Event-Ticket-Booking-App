import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:event_app/admin/admin_dashborad.dart';
import 'package:event_app/admin/subadmin_dashboard.dart';
import 'package:flutter/material.dart';

class SignupAdmin extends StatefulWidget {
  const SignupAdmin({super.key});

  @override
  State<SignupAdmin> createState() => _SignupAdminState();
}

class _SignupAdminState extends State<SignupAdmin> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 30.0),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new_outlined)),
              ],
            ),
            Container(
              height: 300,
              child: Image.asset("assets/images/success.png"),
            ),
            SizedBox(height: 10.0),
            Text(
              "Admin Panel",
              style: TextStyle(
                color: const Color.fromARGB(255, 16, 85, 234),
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.01,
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Username",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 127, 28, 160),
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.01,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: usernamecontroller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Username';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Username..",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Password",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 127, 28, 160),
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.01,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: userpasswordcontroller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Password';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter Password..",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  loginadmin();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                textStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }

  void loginadmin() {
    FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
      bool found = false;
      String userRole = "";

      for (var result in snapshot.docs) {
        if (result.data()['username'] == usernamecontroller.text.trim() &&
            result.data()['password'] == userpasswordcontroller.text.trim()) {
          found = true;
          userRole = result.data()['username'];
          break;
        }
      }

      if (found) {
        // **NEW LOGIC**: Check if the user is the main admin or a sub-admin
        if (userRole == 'admin') {
          // Navigate to the main Admin Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else {
          // Navigate to the Sub-Admin Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SubadminDashboard()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Your id or password is not correct",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    });
  }
}

