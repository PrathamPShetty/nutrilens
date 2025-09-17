import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/diet/diet_cubit.dart';
import '../cubit/diet/diet_state.dart';
import '../../repo/gemini_api.dart';
import '../constants/size_conf.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  bool showVeg = true; // toggle between Veg and Non-Veg

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DietCubit(GeminiApiRepository())..generateWeightLossPlan(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Diet Plan"),
          actions: [
            Switch(
              value: showVeg,
              onChanged: (value) {
                setState(() {
                  showVeg = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(showVeg ? "Veg" : "Non-Veg",
                  style: const TextStyle(fontSize: 16)),
            )
          ],
        ),
        body: BlocBuilder<DietCubit, DietState>(
          builder: (context, state) {
            if (state is DietLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DietLoaded) {
              final plan = state.plan;
              final week1 = plan['dietPlan']?['week1'] as Map<String, dynamic>?;

              if (week1 == null) {
                return const Center(child: Text("No diet plan found."));
              }

              final days = week1.keys.toList();

              return ListView.builder(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final dayName = days[index];
                  final dayPlan = week1[dayName] as Map<String, dynamic>;
                  final typePlan =
                      (showVeg ? dayPlan['veg'] : dayPlan['nonVeg'])
                          as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName[0].toUpperCase() + dayName.substring(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("🍳 Breakfast: ${typePlan['breakfast']?['name']} "
                              "(${typePlan['breakfast']?['calories']} kcal)"),
                          Text("🥗 Lunch: ${typePlan['lunch']?['name']} "
                              "(${typePlan['lunch']?['calories']} kcal)"),
                          Text("🍲 Dinner: ${typePlan['dinner']?['name']} "
                              "(${typePlan['dinner']?['calories']} kcal)"),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is DietError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
