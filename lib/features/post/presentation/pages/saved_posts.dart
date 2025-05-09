import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/post/presentation/cubit/post_state.dart';
import 'package:instagram/features/post/presentation/pages/post_tile.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else if (state is PostsLoaded) {
            final savedPosts = state.posts.where((post) => post.isSaved).toList();

            if (savedPosts.isEmpty) {
              return const Center(
                child: Text(
                  'No saved posts yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                final post = savedPosts[index];
                return PostTile(
                  post: post,
                  onDeletePressed: () {
                    // Handle delete if needed (though saved posts are usually not deletable here)
                    context.read<PostCubit>().toggleSave(post);
                  },
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}