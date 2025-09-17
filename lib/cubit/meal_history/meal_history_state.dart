
import 'package:equatable/equatable.dart';

abstract class MealHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealHistoryInitial extends MealHistoryState {}

class MealHistoryLoading extends MealHistoryState {}

class MealHistoryLoaded extends MealHistoryState {
  final List<Map<String, dynamic>> meals;
  MealHistoryLoaded(this.meals);

  @override
  List<Object?> get props => [meals];
}

class MealHistoryError extends MealHistoryState {
  final String message;
  MealHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
