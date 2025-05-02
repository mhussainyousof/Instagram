import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/data/firebase_auth_repo.dart';
import 'package:instagram/features/auth/home/presentation/pages/home_page.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_state.dart';
import 'package:instagram/features/auth/presentation/pages/auth_page.dart';
import 'package:instagram/features/cloudanity/data/cloudaniry_storage_repo.dart';
import 'package:instagram/features/profile/data/fire_base_profile_repo.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/theme/light_mode.dart';

class MyApp extends StatelessWidget {
   MyApp({super.key});
  
  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebaseProfileRepo = FirebaseProfileRepo();
  final firebaseStorageRepo = CloudinaryStorageRepo();

  @override
  Widget build(BuildContext context) {
    //! provide cubit to app
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepo: firebaseProfileRepo, storageRepo: firebaseStorageRepo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(

          //! listens for error
          listener: (context, state) {
            if(state is AuthError){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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