// File: lib/screens/account.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/bloc/bloc/auth_bloc.dart';
import 'package:client/bloc/bloc_event/auth_event.dart';
import 'package:client/bloc/bloc_state/auth_state.dart';
import 'package:client/widgets/login.dart';
import 'package:client/widgets/signup.dart'; // Import SignUpWidget

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building AccountScreen'); // Debugging statement
    return BlocProvider(
      create: (context) {
        print('Creating AuthBloc in AccountScreen'); // Debugging statement
        final authBloc = AuthBloc()..add(AppStarted());
        print('AuthBloc: AppStarted event added'); // Debugging statement
        return authBloc;
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('AccountScreen state: $state'); // Debugging statement
          if (state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is Authenticated) {
            return const Center(child: Text('Welcome, User!'));
          } else if (state is Unauthenticated) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoginWidget(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpWidget()),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Unknown state.'));
          }
        },
      ),
    );
  }
}
