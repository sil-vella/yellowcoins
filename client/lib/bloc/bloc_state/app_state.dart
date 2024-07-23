import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class InitialState extends AppState {}

class LoadingState extends AppState {}

class LoadedState extends AppState {
  final String data;

  const LoadedState(this.data);

  @override
  List<Object> get props => [data];
}

class ErrorState extends AppState {
  final String message;

  const ErrorState(this.message);

  @override
  List<Object> get props => [message];
}
