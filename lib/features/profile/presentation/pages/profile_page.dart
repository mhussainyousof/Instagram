import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.uid,
    super.key});

  final String uid;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  late AppUser? currentUser = authCubit.currentUser;

  @override
  void initState(){
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
  }
  @override
Widget build(BuildContext context) {
  return BlocBuilder<ProfileCubit, ProfileState>(
    builder: (context, state) {
      if (state is ProfileLoaded) {
        final loadedUser = state.user;
        return Scaffold(
          appBar: AppBar(
            title: Text(loadedUser.name),
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          // body: SingleChildScrollView(
          //   padding: const EdgeInsets.all(16),
          //   child: Column(
          //     children: [
          //       CircleAvatar(
          //         radius: 50,
          //         backgroundImage: NetworkImage(currentUser.profileImageUrl),
          //       ),
          //       const SizedBox(height: 16),
          //       Text(
          //         currentUser.email,
          //         style: Theme.of(context).textTheme.headlineSmall,
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         currentUser.bio,
          //         style: Theme.of(context).textTheme.bodyMedium,
          //         textAlign: TextAlign.center,
          //       ),
          //       // Add more profile fields here
          //     ], 
          //   ),
          // ),
        );
      } else if (state is ProfileLoading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is ProfileError) {
        return Scaffold(
          body: Center(
            child: Text(state.message),
          ),
        );
      } else {
        return const Scaffold(
          body: Center(
            child: Text("No profile found..."),
          ),
        );
      }
    },
  );
}
}