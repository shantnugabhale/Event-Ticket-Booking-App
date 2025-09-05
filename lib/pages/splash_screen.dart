import 'dart:async';
import 'package:event_app/pages/bottomnav.dart';
import 'package:event_app/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late Animation<double> _slideAnimation;
  late Animation<double> _contentFadeAnimation;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeInOutCubic),
    );

    _contentFadeAnimation = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _checkUserAndNavigate();
  }

  /// **IMPROVEMENT**: This function now checks the Firebase auth state directly, which is more reliable.
  void _checkUserAndNavigate() async {
    // **LOGIC CHANGE**: Check for the current user directly from FirebaseAuth.
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Start the splash screen animations
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
        _revealController.forward();
      }
    });

    // Navigate after 4 seconds to the correct page
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            // **LOGIC**: If currentUser is not null, go to Bottomnav, otherwise go to Signup.
            pageBuilder: (_, __, ___) =>
                currentUser != null ? const Bottomnav() : const Signup(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // The main content (icon and text) that is revealed
          if (_showContent)
            Center(
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_activity_outlined,
                      size: 100,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Event App",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 127, 28, 160),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: CurvedAnimation(
                          parent: _revealController,
                          curve: const Interval(0.6, 1.0)),
                      child: Text(
                        "Your next experience awaits.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // The animated curtains that slide away
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Left Curtain
                  Transform.translate(
                    offset: Offset(-_slideAnimation.value * screenWidth / 2, 0),
                    child: _buildCurtain(isLeft: true),
                  ),
                  // Right Curtain
                  Transform.translate(
                    offset: Offset(_slideAnimation.value * screenWidth / 2, 0),
                    child: _buildCurtain(isLeft: false),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget to build a curtain half
  Widget _buildCurtain({required bool isLeft}) {
    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xfff0f2ff), Colors.white],
          ),
        ),
      ),
    );
  }
}

