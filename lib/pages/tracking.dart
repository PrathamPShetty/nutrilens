import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../cubit/nutrition/nutrition_chart_cubit.dart';
import '../cubit/nutrition/nutrition_chart_state.dart';
import '../constants/nutrition_data.dart';

class NutritionChartPage extends StatelessWidget {
  const NutritionChartPage({super.key});

  List<_ChartData> _prepareChartData(List<Map<String, dynamic>> nutritionData) {
    return nutritionData.map((row) {
      return _ChartData(
        row["name"] ?? "Unknown",
        double.tryParse(row["calories"].toString()) ?? 0,
        double.tryParse(row["protein"].toString()) ?? 0,
        double.tryParse(row["fat"].toString()) ?? 0,
        double.tryParse(row["carbs"].toString()) ?? 0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      NutritionChartCubit(NutritionDatabaseHelper())..loadData("today"),
      child: Scaffold(
        appBar: AppBar(title: const Text("Nutrition Chart")),
        body: BlocBuilder<NutritionChartCubit, NutritionChartState>(
          builder: (context, state) {
            if (state is NutritionChartLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NutritionChartLoaded) {
              final chartData = _prepareChartData(state.data);

              return Column(
                children: [
                  // Filter Chips
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text("Today"),
                          selected: state.filter == "today",
                          onSelected: (_) => context
                              .read<NutritionChartCubit>()
                              .loadData("today"),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Week"),
                          selected: state.filter == "week",
                          onSelected: (_) => context
                              .read<NutritionChartCubit>()
                              .loadData("week"),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Year"),
                          selected: state.filter == "year",
                          onSelected: (_) => context
                              .read<NutritionChartCubit>()
                              .loadData("year"),
                        ),
                      ],
                    ),
                  ),

                  // Chart
                  Expanded(
                    child: chartData.isEmpty
                        ? const Center(child: Text("No data available"))
                        : SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(
                          text: "Calories, Protein, Fat & Carbs"),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<dynamic, dynamic>>[
                        ColumnSeries<_ChartData, String>(
                          name: 'Calories',
                          dataSource: chartData,
                          xValueMapper: (d, _) => d.name,
                          yValueMapper: (d, _) => d.calories,
                        ),
                        ColumnSeries<_ChartData, String>(
                          name: 'Protein',
                          dataSource: chartData,
                          xValueMapper: (d, _) => d.name,
                          yValueMapper: (d, _) => d.protein,
                        ),
                        ColumnSeries<_ChartData, String>(
                          name: 'Fat',
                          dataSource: chartData,
                          xValueMapper: (d, _) => d.name,
                          yValueMapper: (d, _) => d.fat,
                        ),
                        ColumnSeries<_ChartData, String>(
                          name: 'Carbs',
                          dataSource: chartData,
                          xValueMapper: (d, _) => d.name,
                          yValueMapper: (d, _) => d.carbs,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is NutritionChartError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _ChartData {
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  _ChartData(this.name, this.calories, this.protein, this.fat, this.carbs);
}
