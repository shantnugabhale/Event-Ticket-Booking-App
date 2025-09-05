import 'package:event_app/pages/signup.dart';
import 'package:event_app/services/auth.dart';
import 'package:event_app/services/database.dart';
import 'package:event_app/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Launches a given URL (for mail or phone).
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Could not launch $url'),
          ),
        );
      }
    }
  }

  /// Shows a dialog to choose between email and call for contacting support.
  void _showContactUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contact Us"),
          content: const Text("How would you like to get in touch?"),
          actions: [
            TextButton(
              child: const Text("Email Us"),
              onPressed: () {
                Navigator.of(context).pop();
                _launchUrl("mailto:shantnugabhale@gmail.com");
              },
            ),
            TextButton(
              child: const Text("Call Us"),
              onPressed: () {
                Navigator.of(context).pop();
                _launchUrl("tel:7796571064");
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog to edit the user's name.
  Future<void> _showEditNameDialog() async {
    final TextEditingController nameController = TextEditingController(
      text: name,
    );
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && id != null) {
                  try {
                    await DatabaseMethods().updateUser(id!, {'name': newName});
                    await SharedPrefenceHelper().savedUserName(newName);

                    setState(() {
                      name = newName;
                    });

                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Name updated successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            'Failed to update name: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: image == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 50.0, bottom: 10.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
                ),
              ),
              child: Column(
                children: [
                  const Text(
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
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        color: Color.fromARGB(255, 249, 249, 249),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20.0),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(90),
                              child: Image.network(
                                image!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 10.0,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Name",
                                          style: TextStyle(
                                            color: Color.fromARGB(118, 0, 0, 0),
                                          ),
                                        ),
                                        Text(name ?? "Not Set"),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.grey,
                                    ),
                                    onPressed: _showEditNameDialog,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Email",
                                        style: TextStyle(
                                          color: Color.fromARGB(118, 0, 0, 0),
                                        ),
                                      ),
                                      Text(email ?? "Not Set"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            GestureDetector(
                              onTap: _showContactUsDialog,
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.contact_emergency,
                                      color: Colors.blue,
                                      size: 30.0,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text("Contact Us"),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            GestureDetector(
                              onTap: () {
                                AuthMethods().SignOut().then((value) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Signup(),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.blue,
                                      size: 30.0,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text("LogOut"),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            GestureDetector(
                              onTap: () {
                                AuthMethods().deleteuser().then(
                                  (value) => {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Signup(),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.blue,
                                      size: 30.0,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text("Delete Account"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
