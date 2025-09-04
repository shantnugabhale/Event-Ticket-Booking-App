import 'package:flutter/material.dart';

class SignupAdmin extends StatefulWidget {
  const SignupAdmin({super.key});

  @override
  State<SignupAdmin> createState() => _SignupAdminState();
}

class _SignupAdminState extends State<SignupAdmin> {
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
                  TextField(
                    decoration: InputDecoration(
                      hint: Text(
                        "Enter Username..",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: const Color.fromARGB(127, 0, 0, 0),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  TextField(
                    decoration: InputDecoration(
                      hint: Text(
                        "Enter Password..",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: const Color.fromARGB(127, 0, 0, 0),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}
