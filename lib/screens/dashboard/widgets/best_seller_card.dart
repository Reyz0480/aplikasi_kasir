import 'package:flutter/material.dart';

class BestSellerCard extends StatelessWidget {
  const BestSellerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "name": "Risol Mayo",
        "sold": "128 Terjual",
        "icon": Icons.fastfood,
      },
      {
        "name": "Es Teh Manis",
        "sold": "102 Terjual",
        "icon": Icons.local_drink,
      },
      {
        "name": "Mie Goreng",
        "sold": "87 Terjual",
        "icon": Icons.ramen_dining,
      },
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(Icons.star,color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Produk Terlaris",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...products.map((product) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Icon(
                  product["icon"] as IconData,
                  color: Colors.deepOrange,
                ),
              ),
              title: Text(product["name"] as String),
              subtitle: Text(product["sold"] as String),
              trailing: const Icon(Icons.arrow_forward_ios,size: 16),
            );
          }),
        ],
      ),
    );
  }
}