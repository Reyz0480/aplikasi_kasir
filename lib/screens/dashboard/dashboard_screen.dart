import 'package:flutter/material.dart';

import 'widgets/dashboard_header.dart';
import 'widgets/statistic_card.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/report_card.dart';
import 'widgets/best_seller_card.dart';
import 'widgets/stock_warning_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xffFFF8F5),

  bottomNavigationBar: const BottomNav(),

  body: SafeArea(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

              const DashboardHeader(),

              const SizedBox(height: 20),

              StatisticCard(
                icon: Icons.payments_outlined,
                title: "Total Penjualan",
                value: "Rp2.450.000",
                subtitle: "▲12% vs Kemarin",
                subtitleColor: Colors.green,
              ),

              StatisticCard(
                icon: Icons.receipt_long,
                title: "Jumlah Transaksi",
                value: "142",
                subtitle: "8 Pesanan Baru",
                subtitleColor: Colors.green,
              ),

              StatisticCard(
                icon: Icons.inventory_2_outlined,
                title: "Produk Terjual",
                value: "384 Pcs",
                subtitle: "Paling Laris : Risol Mayo",
                subtitleColor: Colors.brown,
              ),
const ReportCard(),
const BestSellerCard(),
const StockWarningCard(),
            ],
          ),
        ),
      ),
    );
  }
}