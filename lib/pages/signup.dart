import 'package:event_app/admin/signup_admin.dart'; 
import 'package:event_app/services/auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          child: Column(
            children: [
              Container(
                height: 400,
                child: Image.asset("assets/images/success.png"),
              ),
              SizedBox(height: 10.0),
              Text(
                "Unlock the Future of",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.01,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Event Booking App",
                style: TextStyle(
                  color: const Color.fromARGB(255, 127, 28, 160),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.01,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Discover,book and experience unforgettable moments effortlessly!",
                style: TextStyle(
                  color: const Color.fromARGB(158, 20, 9, 23),
                  fontSize: 16.0,

                  letterSpacing: 0.01,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.0),
              GestureDetector(
                onTap: () {
                  AuthMethods().signInwithGoogle(context);
                },
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Container(
                          height: 30,
                          child: Image.asset("assets/logo/google.png"),
                        ),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.5),
              Text(
                "or",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w100,
                  color: const Color.fromARGB(107, 0, 0, 0),
                ),
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupAdmin()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black54),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Admin Panel",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
