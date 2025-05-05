import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/post/presentation/components/post_tile.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/post/presentation/cubit/post_state.dart';
import 'package:instagram/features/profile/presentation/components/bio_box.dart';
import 'package:instagram/features/profile/presentation/components/follow_button.dart';
import 'package:instagram/features/profile/presentation/components/profile_stats.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_state.dart';
import 'package:instagram/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:instagram/features/profile/presentation/pages/follower_page.dart';
import 'package:instagram/responsive/constrained_scaffold.dart';

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

  int postCount = 0;

  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return; // return if profile is not loaded
    }

    final profileUser = profileState.user;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // Update UI immediately
    setState(() {
      if (isFollowing) {
        // Unfollow
        profileUser.followers.remove(currentUser!.uid);
      } else {
        // Follow
        profileUser.followers.add(currentUser!.uid);
      }
    });

    // Perform actual toggle in cubit
    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      // Revert UI update if there's an error
      setState(() {
        if (isFollowing) {
          // Revert to following state
          profileUser.followers.add(currentUser!.uid);
        } else {
          // Revert to unfollowed state
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final loadedUser = state.user;
          return ConstrainedScaffold(
            appBar: AppBar(
              title: Text(
                loadedUser.name,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              actions: [
                // Edit profile button
                if (isOwnPost)
                  IconButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProfilePage(user: loadedUser),
                          ),
                        ),
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
            body: ListView(
              children: [
                // Email
                Center(
                  child: Text(
                    loadedUser.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                //! Profile picture
                CachedNetworkImage(
                  imageUrl: loadedUser.profileImageUrl,
                  placeholder:
                      (context, url) => const CircularProgressIndicator(),
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.person,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  imageBuilder:
                      (context, imageProvider) => Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 25),

                ProfileStats(
                  postCount: postCount,
                  followerCount: loadedUser.followers.length,
                  followingCount: loadedUser.following.length,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FollowerPage(
                                followers: loadedUser.followers,
                                following: loadedUser.following,
                              ),
                        ),
                      ),
                ),

                const SizedBox(height: 25),
                if (!isOwnPost)
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: loadedUser.followers.contains(
                      currentUser!.uid,
                    ),
                  ),

                const SizedBox(height: 25),
                //! Bio header and box
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
                // list of posts from this user
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    // posts loaded
                    if (state is PostsLoaded) {
                      // filter posts by user id
                      final userPosts =
                          state.posts
                              .where((post) => post.userId == widget.uid)
                              .toList();

                      postCount = userPosts.length;

                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: postCount,
                        itemBuilder: (context, index) {
                          // get individual post
                          final post = userPosts[index];

                          //! return as post tile UI
                          return PostTile(
                            post: post,
                            onDeletePressed:
                                () => context.read<PostCubit>().deletePost(
                                  post.id,
                                ),
                          );
                        },
                      );
                    }
                    //! posts loading
                    else if (state is PostsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return Center(child: Text('No posts yet...'));
                    }
                  },
                ),
              ],
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
