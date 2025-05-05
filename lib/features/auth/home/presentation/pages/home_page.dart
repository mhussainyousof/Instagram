import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:instagram/features/auth/home/presentation/components/my_drawer.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/post/presentation/components/post_tile.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/post/presentation/cubit/post_state.dart';
import 'package:instagram/features/post/presentation/pages/upload_post_page.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/responsive/constrained_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProfileUser? currentProfileUser;
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  void fetchCurrentUserProfile() async {
    final authCubit = context.read<AuthCubit>();
    final currentUserId = authCubit.currentUser?.uid;
    if (currentUserId != null) {
      final user = await profileCubit.getUserProfile(currentUserId);
      setState(() {
        currentProfileUser = user;
      });
    }
  }

  // on startup
  @override
  void initState() {
    super.initState();

    fetchAllPosts();
    fetchCurrentUserProfile();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      // drawer: MyDrawer(),
      // appBar: AppBar(
      //   title: const Text("Home"),
      //   centerTitle: true,
      //   foregroundColor: Theme.of(context).colorScheme.primary,
      //   actions: [
      //     IconButton(
      //       onPressed:
      //           () => Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => UploadPostPage()),
      //           ),
      //      icon: Icon(Iconsax.add_square),
      //     ),
      //   ],
      // ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          //! loading..
          if (state is PostsLoading && state is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          }
          //! loaded
          else if (state is PostsLoaded) {
            final allPosts = state.posts;
            if (allPosts.isEmpty) {
              return const Center(child: Text("No posts available"));
            }
            return SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instagram-like floating add button over profile picture
                    Padding(
    padding: const EdgeInsets.only(top: 30, left: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            currentProfileUser?.profileImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: currentProfileUser!.profileImageUrl,
                    errorWidget: (context, url, error) =>
                        const Icon(Iconsax.user_minus),
                    imageBuilder: (context, imageProvider) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : const Icon(Iconsax.user, size: 40),
            Positioned(
              bottom: 0,
              right: 1,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadPostPage()),
                ),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Icon(
                    Iconsax.add,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'Push To post',
            style: TextStyle(
              fontSize: 10,
              color:Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      ],
    ),
  ),

                    SizedBox(height: 50),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allPosts.length,
                      itemBuilder: (context, index) {
                        //! get individual post
                        final post = allPosts[index];

                        //! image
                        return PostTile(
                          post: post,
                          onDeletePressed: () => deletePost(post.id),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          //! error
          else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text("Error loading posts"));
          }
        },
      ),
    );
  }
}
