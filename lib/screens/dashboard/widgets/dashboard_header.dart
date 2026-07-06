import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(

                  children: [

                    Icon(
                      Icons.storefront_outlined,
                      color: Colors.deepOrange,
                    ),

                    SizedBox(width: 8),

                    Text(
                      "Doyan\nJajan.id",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),

                  ],
                ),

                SizedBox(height: 25),

                Text(
                  "Selamat Datang",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),

                Text(
                  "Kasir",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

          ),

          Column(

            children: [

              Icon(
                Icons.notifications_none,
                size: 28,
              ),

              SizedBox(height: 30),

              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150",
                ),
              ),

              SizedBox(height: 15),

              Container(

                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  "LIVE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),

            ],
          )

        ],
      ),
    );
  }
}