import 'dart:io';
import 'package:event_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';
// Import Firebase Storage for handling file uploads
import 'package:firebase_storage/firebase_storage.dart';

class UploadEvent extends StatefulWidget {
  const UploadEvent({super.key});

  @override
  State<UploadEvent> createState() => _UploadEventState();
}

class _UploadEventState extends State<UploadEvent> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  final List<String> eventcategory = ["Music", "Food", "Party", "Clothes"];
  String? value;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool _isLoading = false; // To show a loading indicator

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
        selectedImage = File(image.path);
        setState(() {});
    }
  }

  DateTime selectDate = DateTime.now();
  TimeOfDay selectTime = TimeOfDay(hour: 10, minute: 00);

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(), // Users can't select a past date
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectDate) {
      setState(() {
        selectDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectTime) {
      setState(() {
        selectTime = pickedTime;
      });
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  // This is the new, robust upload function
  Future<void> uploadEventData() async {
    // --- 1. Input Validation ---
    // Check if essential text fields are filled before proceeding.
    if (namecontroller.text.isEmpty ||
        pricecontroller.text.isEmpty ||
        locationcontroller.text.isEmpty ||
        detailcontroller.text.isEmpty ||
        value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill all the required fields before uploading.'),
        ),
      );
      return; // Stop the function if validation fails
    }

    setState(() {
      _isLoading = true; // Show the loading indicator
    });

    String imageUrl = ""; // Default image URL is an empty string

    try {
      // --- 2. Optional Image Upload ---
      // This block only runs if an image has been selected.
      if (selectedImage != null) {
        String addId = randomAlphaNumeric(10);
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child("eventImages").child(addId);

        final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
        var downloadUrl = await (await task).ref.getDownloadURL();
        imageUrl = downloadUrl; // Assign the uploaded image URL
      }

      // --- 3. Data Preparation & Firestore Upload ---
      String id = randomAlphaNumeric(10);
      String firstletter = namecontroller.text.substring(0, 1).toUpperCase();
      Map<String, dynamic> uploadevent = {
        "Image": imageUrl, // Use the imageUrl (will be "" if no image was selected)
        "Name": namecontroller.text,
        "Price": pricecontroller.text,
        "Category": value,
        "SearchKey": firstletter,
        "Location": locationcontroller.text,
        "Detail": detailcontroller.text,
        "UpdatedName": namecontroller.text.toUpperCase(), // Typo fixed for search
        "Time": formatTimeOfDay(selectTime),
        "Date": DateFormat('yyyy-MM-dd').format(selectDate),
      };

      await DatabaseMethods().addEvent(uploadevent, id);

      // --- 4. Success Feedback ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Event Uploaded Successfully'),
        ),
      );
      // Clear all the fields after a successful upload
      setState(() {
        namecontroller.text = "";
        pricecontroller.text = "";
        locationcontroller.text = "";
        detailcontroller.text = "";
        selectedImage = null;
        value = null; // Also reset the dropdown
      });

    } catch (e) {
      // --- 5. Specific Error Handling ---
      // This will catch any errors during the process and show a message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Upload Failed. Error: ${e.toString()}'),
        ),
      );
    } finally {
      // This ensures the loading indicator is always turned off
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new_outlined)),
                  Spacer(),
                  Text(
                    "Upload Event",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 7, 119, 232),
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 20.0),
              Center(
                child: GestureDetector(
                        onTap: () {
                          getImage();
                        },
                        child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          selectedImage!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.camera_alt_outlined, color: Colors.grey),
                        ),
                      ),
              ),
              SizedBox(height: 15.0),
              Text(
                "Event Name",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Event Name",
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Text(
                "Event Location",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: locationcontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Event Location",
                  ),
                ),
              ),
              SizedBox(height: 15.0),

              Text(
                "Ticket Price",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: pricecontroller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Event Price",
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                "Select Category",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    items: eventcategory
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        value = newValue;
                      });
                    },
                    hint: Text("Select Category"),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.blue),
                  SizedBox(width: 10.0),
                  GestureDetector(
                    onTap: () {
                      _pickDate();
                    },
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(selectDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Icon(Icons.alarm, color: Colors.blue),
                  SizedBox(width: 6.0),
                  GestureDetector(
                    onTap: () {
                      _pickTime();
                    },
                    child: Text(
                      selectTime.format(context),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.0),
              Text(
                "Event Detail",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: detailcontroller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "What will be on that event....",
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Center(
                child: _isLoading 
                ? CircularProgressIndicator()
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // The button now calls our new, safe upload function
                    uploadEventData();
                  },
                  child: Text("Upload"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}