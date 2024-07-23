import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/bloc/bloc_event/app_event.dart';
import 'package:client/bloc/bloc_state/app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(InitialState());

  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is FetchData) {
      yield LoadingState();
      try {
        // Simulate fetching data
        await Future.delayed(const Duration(seconds: 2));
        yield const LoadedState('Fetched Data');
      } catch (e) {
        yield const ErrorState('Failed to fetch data');
      }
    }
  }
}
