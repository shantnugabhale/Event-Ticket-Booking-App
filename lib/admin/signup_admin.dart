import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/admin/admin_dashborad.dart';
import 'package:event_app/admin/subadmin_dashboard.dart'; // <-- IMPORT ADDED
import 'package:flutter/material.dart';

class SignupAdmin extends StatefulWidget {
  const SignupAdmin({super.key});

  @override
  State<SignupAdmin> createState() => _SignupAdminState();
}

class _SignupAdminState extends State<SignupAdmin> {
  // Key to validate the form fields
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  // Controllers to get the text from the TextFormFields
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60.0),
              // Back button to navigate to the previous screen
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios_new_outlined)),
                ],
              ),
              SizedBox(height: 20.0),
              // Decorative image
              Image.asset(
                "assets/images/success.png",
                height: 250,
              ),
              SizedBox(height: 20.0),
              // Title text
              Text(
                "Admin Panel",
                style: TextStyle(
                  color: Color.fromARGB(255, 16, 85, 234),
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.0),
              // Form for username and password
              Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username label
                    Text(
                      "Username",
                      style: TextStyle(
                        color: Color.fromARGB(255, 127, 28, 160),
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Username input field
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
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          color: const Color.fromARGB(127, 0, 0, 0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    // Password label
                    Text(
                      "Password",
                      style: TextStyle(
                        color: Color.fromARGB(255, 127, 28, 160),
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Password input field
                    TextFormField(
                      controller: userpasswordcontroller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Password';
                        }
                        return null;
                      },
                      obscureText: true, // Hides the password
                      decoration: InputDecoration(
                        hintText: "Enter Password..",
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          color: const Color.fromARGB(127, 0, 0, 0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                         prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.0),
              // Login button
              ElevatedButton(
                onPressed: () {
                  // Validate the form before attempting to log in
                  if (_formkey.currentState!.validate()) {
                    loginadmin();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(double.infinity, 50), // Make button wider
                ),
                child: Text("Login"),
              ),
               SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Authenticates the admin and navigates to the correct dashboard based on role.
  void loginadmin() {
    FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
      DocumentSnapshot? userDoc; // Variable to hold the user's document if found

      // Loop through each document to find a matching admin
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['username'] == usernamecontroller.text.trim() &&
            data['password'] == userpasswordcontroller.text.trim()) {
          userDoc = doc; // Store the matched document
          break; // Exit the loop once a match is found
        }
      }

      // After the loop, check if a user was found and navigate accordingly
      if (userDoc != null) {
        final userData = userDoc!.data() as Map<String, dynamic>;
        // Check if the username is 'admin' for the main admin
        if (userData['username'] == 'admin') {
          // Navigate to the Main Admin Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard(docId: userDoc!.id)),
          );
        } else {
          // Otherwise, it's a sub-admin, so navigate to the Sub-Admin Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SubadminDashboard(docId: userDoc!.id)),
          );
        }
      } else {
        // If no match was found after checking all docs, show an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Your ID or password is not correct",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    });
  }
}