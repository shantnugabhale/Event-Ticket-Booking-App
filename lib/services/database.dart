import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  /// Updates a user's details in Firestore.
  Future updateUser(String id, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update(userInfoMap);
  }

  Future addEvent(Map<String, dynamic> eventInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('Event')
        .doc(id)
        .set(eventInfoMap);
  }

  // Method to update an existing event
  Future updateEvent(Map<String, dynamic> eventInfoMap, String docId) async {
    return await FirebaseFirestore.instance
        .collection('Event')
        .doc(docId)
        .update(eventInfoMap);
  }

  // Method to delete an event
  Future deleteEvent(String docId) async {
    return await FirebaseFirestore.instance.collection('Event').doc(docId).delete();
  }

  Stream<QuerySnapshot> getallEvents() {
    return FirebaseFirestore.instance.collection("Event").snapshots();
  }

  Future addUserBooking(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection("Booking")
        .add(userInfoMap);
  }

  Future addAdminTickets(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('Tickets')
        .add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getbookings(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Booking")
        .snapshots();
  }

  Stream<QuerySnapshot> getEventCategories(String category) {
    return FirebaseFirestore.instance
        .collection("Event")
        .where("Category", isEqualTo: category)
        .snapshots();
  }

  Stream<QuerySnapshot> getTickets() {
    return FirebaseFirestore.instance.collection("Tickets").snapshots();
  }
}
