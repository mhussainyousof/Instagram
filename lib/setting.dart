import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/post/presentation/pages/saved_posts.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/profile/presentation/pages/profile_page.dart';
import 'package:instagram/theme/theme_cubit.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<ProfileUser?> _profileFuture;
  late final AuthCubit _authCubit;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = context.read<AuthCubit>();
    _profileCubit = context.read<ProfileCubit>();
    _loadProfile();
  }

  void _loadProfile() {
    final currentUser = _authCubit.currentUser;
    if (currentUser != null) {
      _profileFuture = _profileCubit.getUserProfile(currentUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentUser = _authCubit.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 15),
              child: Column(
                children: [
                  FutureBuilder<ProfileUser?>(
                    future: _profileFuture,
                    builder: (context, snapshot) {
                      final profileUser = snapshot.data;
                      
                      if (profileUser != null) {
                        return Column(
                          children: [
                            // Profile Summary Card
                            Card(
                              elevation: 2,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(uid: currentUser.uid),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Profile Picture
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: profileUser.profileImageUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: profileUser.profileImageUrl,
                                                  placeholder: (context, url) => const Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                  errorWidget: (context, url, error) => const Icon(
                                                    Icons.person,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : const Icon(Icons.person, size: 30, color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Name and Email
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentUser.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              currentUser.email,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const Center(child: Text('Error loading profile'));
                      }
                    },
                  ),


                  // Saved Posts Section
                  _buildListTile(
                    context,
                    title: 'Saved Posts',
                    icon: Icons.bookmark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedPostsScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  // Theme Switcher
                  _ThemeSwitcher(
                    isDarkMode: isDarkMode,
                    onChanged: (value) {
                      themeCubit.toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Logout Button (fixed at bottom)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildListTile(
              context,
              title: 'Logout',
              icon: Icons.logout,
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _authCubit.logout();
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).iconTheme.color),
        title: Text(
          title,
          style: TextStyle(color: titleColor ?? Theme.of(context).textTheme.bodyLarge?.color),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const _ThemeSwitcher({
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).iconTheme.color,
        ),
        title: Text(
          'Dark Mode',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: CupertinoSwitch(
          value: isDarkMode,
          onChanged: onChanged,
        ),
        onTap: () {
          onChanged(!isDarkMode);
        },
      ),
    );
  }
}