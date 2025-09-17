import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/nutrition_data.dart';
import 'nutrition_chart_state.dart';

class NutritionChartCubit extends Cubit<NutritionChartState> {
  final NutritionDatabaseHelper db;

  NutritionChartCubit(this.db) : super(NutritionChartInitial());

  Future<void> loadData(String filter) async {
    try {
      emit(NutritionChartLoading());

      List<Map<String, dynamic>> data = [];
      if (filter == "today") {
        data = await db.getTodayNutrition();
      } else if (filter == "week") {
        data = await db.getThisWeekNutrition();
      } else if (filter == "year") {
        final now = DateTime.now();
        final startOfYear = DateTime(now.year, 1, 1);
        data = await db.getNutritionByDateRange(startOfYear, now);
      }

      emit(NutritionChartLoaded(data, filter));
    } catch (e) {
      emit(NutritionChartError(e.toString()));
    }
  }
}
