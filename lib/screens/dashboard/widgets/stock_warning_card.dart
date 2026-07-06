import 'package:flutter/material.dart';

class StockWarningCard extends StatelessWidget {
  const StockWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lowStock = [
      {"name": "Risol Mayo", "stock": 4},
      {"name": "Sosis Bakar", "stock": 2},
      {"name": "Air Mineral", "stock": 6},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
              SizedBox(width: 8),
              Text(
                "Stok Menipis",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...lowStock.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: const Icon(
                  Icons.inventory,
                  color: Colors.deepOrange,
                ),
              ),
              title: Text(item["name"].toString()),
              trailing: Text(
                "${item["stock"]} pcs",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}