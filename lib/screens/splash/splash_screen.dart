import 'dart:async';

import 'package:flutter/material.dart';

import '../login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Image.asset(
                "lib/img/doyanjajan.jpeg",
                width: 170,
              ),

              const SizedBox(height: 30),

              const Text(
                "Doyan Jajan.id",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffA94400),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Sistem Kasir untuk Jajanan Nagih",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 50),

              const CircularProgressIndicator(
                color: Color(0xffFF641A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}