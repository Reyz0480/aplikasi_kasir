import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      height: 80,

      decoration: const BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.only(

          topLeft: Radius.circular(30),

          topRight: Radius.circular(30),

        ),

      ),

      child: const Row(

        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: [

          Icon(Icons.home,color: Colors.deepOrange),

          Icon(Icons.inventory_2_outlined),

          Icon(Icons.receipt_long),

          Icon(Icons.history),

          Icon(Icons.settings),

        ],

      ),

    );
  }
}