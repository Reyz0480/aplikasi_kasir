import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final String text;

  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      height: 58,

      child: ElevatedButton(

        onPressed: onPressed,

        style: ElevatedButton.styleFrom(

          backgroundColor: const Color(0xffFF641A),

          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(16),

          ),

        ),

        child: Text(

          text,

          style: const TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

    );
  }
}