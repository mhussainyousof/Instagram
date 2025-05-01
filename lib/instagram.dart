import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/data/firebase_auth_repo.dart';
import 'package:instagram/features/auth/post/presentation/pages/home_page.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_state.dart';
import 'package:instagram/features/auth/presentation/pages/auth_page.dart';
import 'package:instagram/theme/light_mode.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  get authRepo => FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    //! provide cubit to app
    return BlocProvider(
      create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if(state is AuthError){
              
            }
          },
          builder: (context, authState) {
            print(authState);
            
            //! unauthorized -> auth page (login/register)
            if (authState is Unauthenticated) {
              return const AuthPage();
            }
            
            //! authenticated -> home page
            if (authState is Authenticated) {
              return const HomePage();
            }
            
            //! loading or initial state
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}