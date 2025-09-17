import 'package:go_router/go_router.dart';
import '../pages/home.dart';
import '../pages/diet.dart';
import '../pages/tracking.dart';
import '../pages/meal_history.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(path: "/dietplan", builder: (context, state) => const DietPlanScreen()),
    GoRoute(path: "/nutritiontracking", builder: (context,state) => const NutritionChartPage()),
    GoRoute(path: "/mealhistory",builder: (context, state)=> const MealHistoryPage() ),

  ],
);
