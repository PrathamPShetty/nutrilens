import 'package:equatable/equatable.dart';

abstract class NutritionChartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NutritionChartInitial extends NutritionChartState {}

class NutritionChartLoading extends NutritionChartState {}

class NutritionChartLoaded extends NutritionChartState {
  final List<Map<String, dynamic>> data;
  final String filter; // today, week, year

  NutritionChartLoaded(this.data, this.filter);

  @override
  List<Object?> get props => [data, filter];
}

class NutritionChartError extends NutritionChartState {
  final String message;
  NutritionChartError(this.message);

  @override
  List<Object?> get props => [message];
}
