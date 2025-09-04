import 'package:event_app/services/database.dart';
import 'package:random_string/random_string.dart';

class TestEvents {
  static Future<void> addSampleEvents() async {
    final database = DatabaseMethods();
    
    // Sample Food events
    await database.addEvent({
      "Image": "",
      "Name": "Food Festival 2024",
      "Price": "25",
      "Category": "Food",
      "Location": "Central Park",
      "Detail": "Amazing food festival with local and international cuisine",
      "Time": "18:00",
      "Date": "2024-12-25",
    }, randomAlphaNumeric(10));
    
    await database.addEvent({
      "Image": "",
      "Name": "Pizza Night",
      "Price": "15",
      "Category": "Food",
      "Location": "Downtown Plaza",
      "Detail": "Best pizza in town with live music",
      "Time": "19:30",
      "Date": "2024-12-28",
    }, randomAlphaNumeric(10));
    
    // Sample Music events
    await database.addEvent({
      "Image": "",
      "Name": "Rock Concert",
      "Price": "50",
      "Category": "Music",
      "Location": "Stadium Arena",
      "Detail": "Amazing rock concert with famous bands",
      "Time": "20:00",
      "Date": "2024-12-30",
    }, randomAlphaNumeric(10));
    
    await database.addEvent({
      "Image": "",
      "Name": "Jazz Night",
      "Price": "30",
      "Category": "Music",
      "Location": "Jazz Club",
      "Detail": "Smooth jazz evening with local artists",
      "Time": "21:00",
      "Date": "2024-12-27",
    }, randomAlphaNumeric(10));
    
    // Sample Clothes events
    await database.addEvent({
      "Image": "",
      "Name": "Fashion Show",
      "Price": "40",
      "Category": "Clothes",
      "Location": "Fashion Center",
      "Detail": "Latest fashion trends and designer collections",
      "Time": "19:00",
      "Date": "2024-12-26",
    }, randomAlphaNumeric(10));
    
    await database.addEvent({
      "Image": "",
      "Name": "Vintage Market",
      "Price": "10",
      "Category": "Clothes",
      "Location": "Old Town Square",
      "Detail": "Vintage clothing and accessories market",
      "Time": "10:00",
      "Date": "2024-12-29",
    }, randomAlphaNumeric(10));
    
    print("Sample events added successfully!");
  }
}
