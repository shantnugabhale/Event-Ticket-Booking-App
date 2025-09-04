import 'package:event_app/pages/bottomnav.dart';
import 'package:event_app/services/database.dart';
import 'package:event_app/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() {
    return auth.currentUser;
  }

  signInwithGoogle(BuildContext context) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Sign in with Google
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();

      if (googleSignInAccount == null) {
        // User cancelled the sign-in
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      // Create credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      // Sign in to Firebase
      UserCredential result = await firebaseAuth.signInWithCredential(
        credential,
      );
      User? userDetails = result.user;
      if (userDetails == null) {
        return null;
      }
      await SharedPrefenceHelper()
          .savedUserEmail(userDetails.email ?? "");
      await SharedPrefenceHelper()
          .savedUserName(userDetails.displayName ?? "");
      await SharedPrefenceHelper()
          .savedUserImage(userDetails.photoURL ?? "");
      await SharedPrefenceHelper().savedUserId(userDetails.uid);

      if (result.user != null) {
        Map<String, dynamic> userInfoMap = {
          "Name": userDetails.displayName,
          "Image": userDetails.photoURL,
          "Email": userDetails.email,
          "Id": userDetails.uid,
        };

        await DatabaseMethods().addUserDetails(userInfoMap, userDetails.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Registration successful'),
            ),
          );
          // Navigate to HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Bottomnav()),
          );
        }
        return userDetails;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Sign in failed: ${e.toString()}'),
          ),
        );
      }
      // Log error for debugging (remove in production)
      debugPrint('Google Sign-In Error: $e');
    }
    return null;
  }

  Future SignOut() async {
    await FirebaseAuth.instance.signOut();
  }

   Future deleteuser() async {
    User? user = await FirebaseAuth.instance.currentUser;
    user?.delete();
  }
}
