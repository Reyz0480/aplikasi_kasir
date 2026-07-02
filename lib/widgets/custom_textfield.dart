import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(

            hintText: hint,

            prefixIcon: Icon(icon),

            suffixIcon: suffixIcon,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}