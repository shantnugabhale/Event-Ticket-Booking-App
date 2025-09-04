
import 'package:event_app/pages/signup.dart';
import 'package:event_app/pages/splash_screen.dart';
import 'package:event_app/services/data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


void main () async{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey=publishedkey;
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Event Management App",
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
    );
  }
}