import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditSubadminPage extends StatefulWidget {
  final String docId;
  final String currentUsername;
  final String currentPassword;

  const EditSubadminPage({
    super.key,
    required this.docId,
    required this.currentUsername,
    required this.currentPassword,
  });

  @override
  State<EditSubadminPage> createState() => _EditSubadminPageState();
}

class _EditSubadminPageState extends State<EditSubadminPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text fields with the current admin data
    _usernameController = TextEditingController(text: widget.currentUsername);
    _passwordController = TextEditingController(text: widget.currentPassword);
  }

  /// Updates the admin document in Firestore.
  Future<void> _updateSubadmin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
      };
      // Update the document with the new data
      await FirebaseFirestore.instance.collection('Admin').doc(widget.docId).update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Admin updated successfully!'),
        ),
      );
      // Go back to the previous page after successful update
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update admin: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Admin Details"),
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
                Text("Username", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
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
                    hintText: "Update username",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 30),
                Text("Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Update password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 40),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _updateSubadmin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: Text("Update Details"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
