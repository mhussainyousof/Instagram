import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/profile/presentation/components/bio_box.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_state.dart';
import 'package:instagram/features/profile/presentation/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({required this.uid, super.key});

  final String uid;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  late AppUser? currentUser = authCubit.currentUser;

  @override
  void initState() {
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
  title: Text(
    loadedUser.name,
    style: TextStyle(
      color: Theme.of(context).colorScheme.primary,
    ),
  ),
  foregroundColor: Theme.of(context).colorScheme.primary,
  backgroundColor: Theme.of(context).colorScheme.surface,
  elevation: 0,
  actions: [
    // Edit profile button
    IconButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(user: loadedUser),
        ),
      ),
      icon: Icon(
        Icons.settings_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  ],
),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    // Email
                    Text(
                      loadedUser.email,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 25),
                    //! Profile picture
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 120,
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Bio header and box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bio",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    BioBox(text: loadedUser.bio),
                    const SizedBox(height: 25),

                    // Posts header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Text(
                            "Posts",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ProfileError) {
          return Scaffold(body: Center(child: Text(state.message)));
        } else {
          return const Scaffold(
            body: Center(child: Text("No profile found...")),
          );
        }
      },
    );
  }
}
