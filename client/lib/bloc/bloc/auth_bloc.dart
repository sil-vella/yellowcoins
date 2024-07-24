// File: lib/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/bloc/bloc_event/auth_event.dart';
import 'package:client/bloc/bloc_state/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    print('AuthBloc initialized'); // Debugging statement
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    print('AuthBloc received event: AppStarted'); // Debugging statement
    emit(AuthLoading());
    print('AuthBloc state: AuthLoading'); // Debugging statement
    final isLoggedIn = await _checkIfLoggedIn();
    if (isLoggedIn) {
      emit(Authenticated());
      print('AuthBloc state: Authenticated'); // Debugging statement
    } else {
      emit(Unauthenticated());
      print('AuthBloc state: Unauthenticated'); // Debugging statement
    }
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) {
    print('AuthBloc received event: LoggedIn'); // Debugging statement
    emit(Authenticated());
    print('AuthBloc state: Authenticated'); // Debugging statement
  }

  void _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) {
    print('AuthBloc received event: LoggedOut'); // Debugging statement
    emit(Unauthenticated());
    print('AuthBloc state: Unauthenticated'); // Debugging statement
  }

  Future<bool> _checkIfLoggedIn() async {
    await Future.delayed(Duration(seconds: 2));
    return false; // Change this to true to simulate a logged-in user
  }
}
