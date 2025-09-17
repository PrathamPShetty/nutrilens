import 'package:flutter_bloc/flutter_bloc.dart';
import 'diet_state.dart';
import '../../repo/gemini_api.dart';

class DietCubit extends Cubit<DietState> {
  final GeminiApiRepository repo;

  DietCubit(this.repo) : super(DietInitial());

  Future<void> generateWeightLossPlan() async {
    try {
      emit(DietLoading());
      final plan = await repo.generateWeightLossPlan();
      print(plan);
      emit(DietLoaded(plan));
    } catch (e) {
      emit(DietError(e.toString()));
    }
  }
}
