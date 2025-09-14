part of 'home_cubit.dart';

abstract class NutritionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NutritionInitial extends NutritionState {}

class NutritionLoading extends NutritionState {}

class NutritionLoaded extends NutritionState {
  final Map<String, dynamic> nutritionData;

  NutritionLoaded(this.nutritionData);

  @override
  List<Object?> get props => [nutritionData];
}

class NutritionError extends NutritionState {
  final String error;

  NutritionError(this.error);

  @override
  List<Object?> get props => [error];
}

class NutritionEmpty extends NutritionState {}