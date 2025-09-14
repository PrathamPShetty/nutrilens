import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nutrilens/constants/nutrition_data.dart';
import 'package:nutrilens/repo/gemini_api.dart';

part 'home_state.dart';

class NutritionCubit extends Cubit<NutritionState> {
  final GeminiApiRepository geminiApiRepository;

  NutritionCubit(this.geminiApiRepository) : super(NutritionInitial());

  Future<void> analyzeImage(File imageFile) async {
    emit(NutritionLoading());

    try {
      final result = await geminiApiRepository.analyzeImage(imageFile);
      if (result.isEmpty ) {
        emit(NutritionError("No nutrition details found. Please try again."));
        return;
      }
      if(result['nameOfFood'] == null ) {
        emit(NutritionError("No nutrition details found. Please try again."));
        return;
      }
      emit(NutritionLoaded(result));
    } catch (e) {
      emit(NutritionError(e.toString()));
    }
  }
  void reset() {
    emit(NutritionInitial());
  }

  Future<void> saveDeit() async {
   await  SharedPrefHelper.saveNutritionData((state as NutritionLoaded).nutritionData);
    emit(NutritionEmpty());
  }
}
