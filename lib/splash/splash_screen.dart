import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gnotes/home/presentation/home_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    authenticateWithBiometrics();
    super.initState();
  }

  void takeToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (c) => const HomeScreen(),
      ),
    );
  }

  String errorMsg = "";

  void authenticateWithBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to access G Notes');

      if (didAuthenticate) {
        HapticFeedback.mediumImpact();
        takeToHome();
      }
      // ···
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        log("Not enrolled");
        setState(() {
          errorMsg =
              "Please enroll biometrics to enable authentication on Gnotes";
        });
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        setState(() {
          errorMsg =
              "Authentication API is locked out. Possible reason may be due to too many attempts.";
        });
        log("locked out");
      } else {
        setState(() {
          errorMsg =
              "Something went wrong while authenticating. Please try checking your biometrics on the device.";
        });
        log("something else");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/images/play_store_512.png",
                    fit: BoxFit.scaleDown,
                    height: 100,
                    width: 100,
                  )),
              const SizedBox(
                height: 24,
              ),
              const Text(
                "Welcome to G Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                errorMsg,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
