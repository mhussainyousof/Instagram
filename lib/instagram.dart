import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/data/firebase_auth_repo.dart';
import 'package:instagram/features/auth/home/presentation/pages/home_page.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_state.dart';
import 'package:instagram/features/auth/presentation/pages/auth_page.dart';
import 'package:instagram/features/cloudanity/data/cloudaniry_storage_repo.dart';
import 'package:instagram/features/post/data/firebase_post_repo.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/profile/data/fire_base_profile_repo.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/search/data/firebase_search_repo.dart';
import 'package:instagram/features/search/presentation/cubit/search_cubit.dart';
import 'package:instagram/theme/theme_cubit.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebaseProfileRepo = FirebaseProfileRepo();
  final firebaseStorageRepo = CloudinaryStorageRepo();
  final firebasePostRepo = FirebasePostRepo();
  final firebaseSearchRepo = FirebaseSearchRepo();

  @override
  Widget build(BuildContext context) {
    //! provide cubit to app
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create:
              (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create:
              (context) => ProfileCubit(
                profileRepo: firebaseProfileRepo,
                storageRepo: firebaseStorageRepo,
              ),
        ),
        BlocProvider<PostCubit>(
          create:
              (context) => PostCubit(
                storageRepo: firebaseStorageRepo,
                postRepo: firebasePostRepo,
              ),
        ),
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(searchRepo: firebaseSearchRepo),
        ),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder:
            (context, currentTheme) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: currentTheme,
              home: BlocConsumer<AuthCubit, AuthState>(
                //! listens for error
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, authState) {
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
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
      ),
    );
  }
}
