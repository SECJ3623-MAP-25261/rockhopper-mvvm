// lib/view/profile/rentee_chart.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../view_model/chart_viewmodel.dart';
import '../../view_model/chart_ui_data.dart';

class RenteeChartScreen extends StatelessWidget {
  const RenteeChartScreen({super.key});

Color _monthColor(int index) {
  const colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.teal,
    Colors.cyan,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];
  return colors[index % colors.length];
}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChartViewModel()..loadEarnings(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Rentee Activity Insight")),
        body: Consumer<ChartViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.errorMessage != null) {
              return Center(child: Text(vm.errorMessage!));
            }

            if (vm.chartData.isEmpty) {
              return const Center(child: Text("No earnings data available."));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Toggle: Monthly / Overall
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Monthly"),
                        selected: vm.selectedRange == ChartRange.monthly,
                        onSelected: (val) {
                          if (val) vm.changeRange(ChartRange.monthly);
                        },
                      ),
                      const SizedBox(width: 5),
                      ChoiceChip(
                        label: const Text("Overall"),
                        selected: vm.selectedRange == ChartRange.overall,
                        onSelected: (val) {
                          if (val) vm.changeRange(ChartRange.overall);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BarChart(
                     BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: vm.chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final data = vm.chartData[groupIndex];
                            return BarTooltipItem(
                              "${data.label}\nRM${data.value.toStringAsFixed(2)}",
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) => Text("RM${value.toInt()}"),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= vm.chartData.length) return const Text("");
                              return Text(vm.chartData[index].label);
                            },
                          ),
                        ),
                      ),
                      barGroups: vm.chartData
                          .asMap()
                          .entries
                          .map((entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.value,
                                    color: _monthColor(entry.key),
                                    width: 20,
                                  )
                                ],
                              ))
                          .toList(),
                    )

                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Total Earned: RM${vm.totalEarned.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
