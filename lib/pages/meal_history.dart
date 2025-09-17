import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/meal_history/meal_history_cubit.dart';
import '../cubit/meal_history/meal_history_state.dart';
import '../constants/nutrition_data.dart';
import 'package:intl/intl.dart';

class MealHistoryPage extends StatelessWidget {
  const MealHistoryPage({super.key});

  String formatTime(String? rawTime) {
    if (rawTime == null) return "Unknown Time";
    try {
      final date = DateTime.parse(rawTime);
      return DateFormat('dd MMM, hh:mm a').format(date);
    } catch (_) {
      return rawTime;
    }
  }


  String _getMealType(String? timestamp) {
    if (timestamp == null) return "Snack";
    try {
      final time = DateTime.parse(timestamp);
      final hour = time.hour;

      if (hour >= 5 && hour < 11) return "Breakfast";
      if (hour >= 11 && hour < 16) return "Lunch";
      if (hour >= 16 && hour < 21) return "Dinner";
      return "Snack";
    } catch (_) {
      return "Snack";
    }
  }



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      MealHistoryCubit(NutritionDatabaseHelper())..loadMeals(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Meal History")),
        body: BlocBuilder<MealHistoryCubit, MealHistoryState>(
          builder: (context, state) {
            if (state is MealHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MealHistoryLoaded) {
              if (state.meals.isEmpty) {
                return const Center(child: Text("No meals recorded yet."));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: state.meals.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final meal = state.meals[index];
                  return ListTile(
                    leading: Icon(
                      meal['mealType'] == "Breakfast"
                          ? Icons.free_breakfast
                          : meal['mealType'] == "Lunch"
                          ? Icons.lunch_dining
                          : Icons.dinner_dining,
                      color: Colors.green,
                    ),
                    title: Text(meal['name'] ?? "Unknown Meal"),
                    subtitle: Text(
                      "${_getMealType(meal['timestamp'] as String?)} • ${formatTime(meal['timestamp'] as String?)}",
                    ),

                    trailing: const Icon(Icons.fastfood, color: Colors.orange),
                  );
                },
              );
            } else if (state is MealHistoryError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
