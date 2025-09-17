
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/nutrition_data.dart';
import 'meal_history_state.dart';

class MealHistoryCubit extends Cubit<MealHistoryState> {
  final NutritionDatabaseHelper db;

  MealHistoryCubit(this.db) : super(MealHistoryInitial());

  Future<void> loadMeals() async {
    try {
      emit(MealHistoryLoading());
      final meals = await db.getAllMealsSorted();
      emit(MealHistoryLoaded(meals));
    } catch (e) {
      emit(MealHistoryError(e.toString()));
    }
  }
}
