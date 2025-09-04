import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateSubadminPage extends StatefulWidget {
  const CreateSubadminPage({super.key});

  @override
  State<CreateSubadminPage> createState() => _CreateSubadminPageState();
}

class _CreateSubadminPageState extends State<CreateSubadminPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Function to add a new admin to the Firestore database.
  Future<void> _createSubadmin() async {
    // First, validate the form to ensure fields are not empty.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Prepare the data to be uploaded.
      final Map<String, dynamic> subadminData = {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        // You can add more fields here, like 'role': 'subadmin'
      };

      // Add the new document to the 'Admin' collection.
      await FirebaseFirestore.instance.collection('Admin').add(subadminData);

      // Show a success message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Subadmin created successfully!'),
        ),
      );

      // Clear the text fields after successful creation.
      _usernameController.clear();
      _passwordController.clear();

    } catch (e) {
      // Show an error message if something goes wrong.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to create subadmin: ${e.toString()}'),
        ),
      );
    } finally {
      // This will always run, whether there was an error or not.
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Subadmin"),
        backgroundColor: Color(0xffe3e6ff),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "New Admin Username",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 127, 28, 160),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter new username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person_add_alt_1),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "New Admin Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                     color: Color.fromARGB(255, 127, 28, 160),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter new password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                     prefixIcon: Icon(Icons.password),
                  ),
                ),
                SizedBox(height: 40),
                // Show a loading circle or the button.
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _createSubadmin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text("Create Admin"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
