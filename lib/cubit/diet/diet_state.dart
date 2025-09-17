abstract class DietState {}

class DietInitial extends DietState {}

class DietLoading extends DietState {}

class DietLoaded extends DietState {
  final Map<String, dynamic> plan;
  DietLoaded(this.plan);
}

class DietError extends DietState {
  final String message;
  DietError(this.message);
}
