import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/colors/theme_cubit.dart';
import 'package:instagram/features/auth/data/firebase_auth_repo.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_state.dart';
import 'package:instagram/features/auth/presentation/pages/auth_page.dart';
import 'package:instagram/features/cloudanity/data/cloudaniry_storage_repo.dart';
import 'package:instagram/features/general/home_navigation.dart';
import 'package:instagram/features/post/data/firebase_post_repo.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/profile/data/fire_base_profile_repo.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/search/data/firebase_search_repo.dart';
import 'package:instagram/features/search/presentation/cubit/search_cubit.dart';
import 'package:instagram/responsive/constrained_scaffold.dart';


class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebaseProfileRepo = FirebaseProfileRepo();
  final firebaseStorageRepo = CloudinaryStorageRepo();
  final firebasePostRepo = FirebasePostRepo();
  final firebaseSearchRepo = FirebaseSearchRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
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
        builder: (context, currentTheme) => 
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: currentTheme,
          home: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, authState) {
              if (authState is Unauthenticated) {
                return const AuthPage();
              }

              if (authState is Authenticated) {
                return const MainNavigation();
              }

              return const ConstrainedScaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }
}