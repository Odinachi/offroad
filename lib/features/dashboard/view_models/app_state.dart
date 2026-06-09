part of 'app_cubit.dart';

abstract class AppState extends Equatable {}

class AppInitial extends AppState {
  @override
  List<Object?> get props => [];
}


class AppUpdated extends AppState {
  @override
  List<Object?> get props => [Random().nextInt(10)];
}
