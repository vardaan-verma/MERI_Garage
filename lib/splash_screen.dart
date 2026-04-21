import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay before navigating to the next screen
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Set the background using backgroundsplashscreen.png
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundsplashscreen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Logo
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 175, // Adjust the size as needed
                height: 175,
              ),
            ),
            // Bottom "Meri Garage" Image text/logo
            Positioned(
              bottom: 50.0, // Adjust distance from the bottom
              child: Image.asset(
                'assets/images/MeriGarage.png',
                width: 150, // Adjust the size as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
