import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'package:aplikasi_kasir/screens/dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),

            child: Column(
              children: [

                const SizedBox(height: 30),

                Image.asset(
                  "lib/img/doyanjajan.jpeg",
                  height: 170,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Doyan\nJajan.id",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffA94400),
                    height: 1,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Sistem Kasir untuk Jajanan Nagih",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 35),

                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(25),

                    border: Border.all(
                      color: Colors.orange.shade100,
                    ),
                  ),

                  child: Column(
                    children: [

                      CustomTextField(
                        label: "Username",
                        hint: "Masukkan username",
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 20),

                      CustomTextField(
                        label: "Kata Sandi",
                        hint: "Masukkan kata sandi",
                        icon: Icons.lock_outline,
                        obscure: hidePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [

                          Checkbox(
                            value: rememberMe,
                            onChanged: (v) {
                              setState(() {
                                rememberMe = v!;
                              });
                            },
                          ),

                          const Text("Ingat Saya"),

                          const Spacer(),

                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Lupa Sandi?",
                              style: TextStyle(
                                color: Color(0xffFF641A),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      CustomButton(
                        text: "Masuk Sekarang",
                        onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const DashboardScreen(),
    ),
  );
},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}