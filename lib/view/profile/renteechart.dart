import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinjamtech_app/services/renteechartservice.dart';

class RenteeChart extends StatefulWidget {
  const RenteeChart({super.key});

  @override
  State<RenteeChart> createState() => _RenteeChartState();
}

class _RenteeChartState extends State<RenteeChart> {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  bool isMonthly = true;
  bool isLoading = true;

  int overallTotalRentals = 0;
  double totalEarned = 0;
 List<Map<String, dynamic>> monthlySummary = [];


  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    final renteeId =
        Supabase.instance.client.auth.currentUser!.id;

    overallTotalRentals =
        await RenteeChartService.fetchOverallRentals(renteeId);

   monthlySummary =
    await RenteeChartService.fetchMonthlySummary(renteeId);


    totalEarned =
        await RenteeChartService.fetchTotalEarned(renteeId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentee Analysis'),
        backgroundColor: primaryGreen,
      ),
      backgroundColor: backgroundGrey,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [!isMonthly, isMonthly],
              onPressed: (index) {
                setState(() => isMonthly = index == 1);
              },
              selectedColor: Colors.white,
              fillColor: primaryGreen,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Overall'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Monthly'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : isMonthly
                      ? buildMonthlyChart()
                      : buildOverallCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOverallCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('Total Rentals',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  overallTotalRentals.toString(),
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('Total Earned (RM)',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  totalEarned.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
Widget buildMonthlyChart() {
  if (monthlySummary.isEmpty) {
    return const Center(child: Text('No data available'));
  }

  // Find max values for scaling
  final maxRental = monthlySummary
      .map((e) => e['total_rentals'] as int)
      .reduce((a, b) => a > b ? a : b)
      .toDouble();

  final maxEarned = monthlySummary
      .map((e) => (e['total_earned'] as num).toDouble())
      .reduce((a, b) => a > b ? a : b);

  final maxY = (maxRental > maxEarned ? maxRental : maxEarned) + 5;

  // Bar groups for total rentals
  final barGroups = monthlySummary.map((item) {
    return BarChartGroupData(
      x: item['month'],
      barRods: [
        BarChartRodData(
          toY: (item['total_rentals'] as int).toDouble(),
          width: 18,
          color: primaryGreen,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }).toList();

  // Line spots for total earned
  final lineSpots = monthlySummary.map((item) {
    return FlSpot(
      item['month'].toDouble(),
      (item['total_earned'] as num).toDouble(),
    );
  }).toList();

  return Stack(
    children: [
      // Bar chart for rentals
      BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: barGroups,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text('M${value.toInt()}'),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
        ),
      ),
      // Line chart for total earned
      LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: lineSpots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
        ),
      ),
    ],
  );
}


}
