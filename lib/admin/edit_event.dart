import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; 
import 'package:random_string/random_string.dart';

class EditEventPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> eventData;

  const EditEventPage({
    super.key,
    required this.docId,
    required this.eventData,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  // Text editing controllers
  late TextEditingController namecontroller;
  late TextEditingController pricecontroller;
  late TextEditingController locationcontroller;
  late TextEditingController detailcontroller;
  final TextEditingController _imageUrlController = TextEditingController();

  // State variables
  final List<String> eventcategory = ["Music", "Food", "Party", "Clothes"];
  String? value;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String? currentImageUrl;
  bool _isLoading = false;
  DateTime? selectDate;
  TimeOfDay? selectTime;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers and state variables with existing event data
    namecontroller = TextEditingController(text: widget.eventData['Name']);
    pricecontroller = TextEditingController(text: widget.eventData['Price']);
    locationcontroller = TextEditingController(text: widget.eventData['Location']);
    detailcontroller = TextEditingController(text: widget.eventData['Detail']);
    value = widget.eventData['Category'];
    currentImageUrl = widget.eventData['Image'];
    selectDate = DateTime.parse(widget.eventData['Date']);
    _imageUrlController.text = currentImageUrl ?? '';
    
    // --- FIX: Robust time parsing to handle both 12-hour and 24-hour formats ---
    try {
      final timeString = widget.eventData['Time'] as String;
      // Try parsing 12-hour format first (e.g., "5:08 PM")
      final format12 = DateFormat.jm(); 
      final dateTime = format12.parse(timeString);
      selectTime = TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      try {
        // If that fails, try parsing 24-hour format (e.g., "17:08")
        final timeString = widget.eventData['Time'] as String;
        final format24 = DateFormat.Hm();
        final dateTime = format24.parse(timeString);
        selectTime = TimeOfDay.fromDateTime(dateTime);
      } catch (e2) {
        // If both fail, default to the current time as a fallback
        print("Error parsing time string: ${widget.eventData['Time']}. Defaulting to now.");
        selectTime = TimeOfDay.now();
      }
    }
  }

  @override
  void dispose() {
    namecontroller.dispose();
    pricecontroller.dispose();
    locationcontroller.dispose();
    detailcontroller.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Opens the gallery to pick a new image.
  Future<void> getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        currentImageUrl = null; // Clear URL if an image is picked
        _imageUrlController.clear();
      });
    }
  }
  
  /// Shows a dialog to input an image URL.
  Future<void> _showImageUrlDialog() async {
    _imageUrlController.text = currentImageUrl ?? '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(
          controller: _imageUrlController,
          decoration: const InputDecoration(hintText: 'https://...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context, _imageUrlController.text),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        currentImageUrl = result;
        selectedImage = null; // Clear selected image if URL is provided
      });
    }
  }

  /// Handles the complete event update logic.
  Future<void> updateEventData() async {
    // --- 1. Input Validation ---
    if (namecontroller.text.isEmpty ||
        pricecontroller.text.isEmpty ||
        locationcontroller.text.isEmpty ||
        detailcontroller.text.isEmpty ||
        value == null ||
        selectDate == null ||
        selectTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill all the required fields.'),
        ),
      );
      return;
    }
    
    if (selectedImage == null && (currentImageUrl == null || currentImageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please select an image or provide an image URL.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String imageUrl = currentImageUrl ?? "";

    try {
      // --- 2. Image Handling (if a new image was selected) ---
      if (selectedImage != null) {
        String addId = randomAlphaNumeric(10);
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child("eventImages").child(addId);
        final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
        var downloadUrl = await (await task).ref.getDownloadURL();
        imageUrl = downloadUrl;
      } else {
        imageUrl = currentImageUrl!;
      }

      // --- 3. Data Preparation & Firestore Update ---
      Map<String, dynamic> updatedEvent = {
        "Image": imageUrl,
        "Name": namecontroller.text,
        "Price": pricecontroller.text,
        "Category": value,
        "Location": locationcontroller.text,
        "Detail": detailcontroller.text,
        "UpdatedName": namecontroller.text.toUpperCase(),
        "Time": selectTime!.format(context),
        "Date": DateFormat('yyyy-MM-dd').format(selectDate!),
      };

      await FirebaseFirestore.instance
          .collection('Event')
          .doc(widget.docId)
          .update(updatedEvent);

      // --- 4. Success Feedback & Navigation ---
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Event Updated Successfully'),
        ),
      );
      Navigator.of(context).pop(); // Go back to the manage events page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Update Failed. Error: ${e.toString()}'),
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
        title: const Text("Edit Event"),
        centerTitle: true,
        backgroundColor: const Color(0xfff0f2ff),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff0f2ff), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePreview(),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(child: _buildOptionButton(
                    "Pick From Gallery", Icons.image_outlined, getImage)),
                  const SizedBox(width: 16.0),
                  Expanded(child: _buildOptionButton(
                    "Use Image URL", Icons.link, _showImageUrlDialog)),
                ],
              ),
              const SizedBox(height: 24.0),
              _buildDropdown(),
              const SizedBox(height: 16.0),
              _buildTextField(controller: namecontroller, hint: "Event Name"),
              const SizedBox(height: 16.0),
              _buildTextField(controller: locationcontroller, hint: "Location"),
              const SizedBox(height: 16.0),
              _buildTextField(controller: pricecontroller, hint: "Price", keyboardType: TextInputType.number),
              const SizedBox(height: 16.0),
              _buildDateTimePickers(),
              const SizedBox(height: 16.0),
              _buildTextField(controller: detailcontroller, hint: "Details", maxLines: 5),
              const SizedBox(height: 32.0),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildImagePreview() {
    Widget content;
    if (selectedImage != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.file(selectedImage!, fit: BoxFit.cover),
      );
    } else if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.network(
          currentImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
          ),
        ),
      );
    } else {
      content = const Center(
        child: Icon(Icons.image_search, color: Colors.black54, size: 60),
      );
    }
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: content,
    );
  }

  Widget _buildOptionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blue.shade800,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        elevation: 2,
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text("Select Category"),
          isExpanded: true,
          items: eventcategory.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              value = newValue;
            });
          },
        ),
      ),
    );
  }
  
  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: selectDate ?? DateTime.now(),
              );
              if (pickedDate != null) setState(() => selectDate = pickedDate);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
              child: Text(
                selectDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(selectDate!),
                style: TextStyle(fontSize: 16, color: selectDate == null ? Colors.grey.shade600 : Colors.black),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: selectTime ?? TimeOfDay.now(),
              );
              if (pickedTime != null) setState(() => selectTime = pickedTime);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
              child: Text(
                selectTime == null ? "Select Time" : selectTime!.format(context),
                style: TextStyle(fontSize: 16, color: selectTime == null ? Colors.grey.shade600 : Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return GestureDetector(
      onTap: _isLoading ? null : updateEventData,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : const Text(
                  "Update Event",
                  style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}

