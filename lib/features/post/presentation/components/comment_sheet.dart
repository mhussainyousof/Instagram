import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/post/domain/entity/comment.dart';
import 'package:instagram/features/post/domain/entity/post.dart';
import 'package:instagram/features/post/presentation/components/comment_input.dart';
import 'package:instagram/features/post/presentation/components/comment_tile.dart';

import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/post/presentation/cubit/post_state.dart';

class CommentSheet extends StatelessWidget {
  final Post post;

  const CommentSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder:
          (_, controller) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: BlocBuilder<PostCubit, PostState>(
                    builder: (context, state) {
                      if (state is PostsLoaded) {
                        final latestPost = state.posts.firstWhere(
                          (p) => p.id == post.id,
                        );
                        return CommentList(
                          post: latestPost,
                          controller: controller,
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ),

                CommentInput(
                  postId: post.id,
                  onCommentAdded: (text) => _addComment(context, text),
                ),
              ],
            ),
          ),
    );
  }

  void _addComment(BuildContext context, String text) {
    final postCubit = context.read<PostCubit>();
    final currentUser = context.read<AuthCubit>().currentUser!;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: post.id,
      userId: currentUser.uid,
      userName: currentUser.name,
      text: text,
      timestamp: DateTime.now(),
    );

    postCubit.addComment(post.id, newComment);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text('Comments', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class CommentList extends StatelessWidget {
  final Post post;
  final ScrollController controller;

  const CommentList({super.key, required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: post.comments.length,
      itemBuilder: (_, index) => CommentTile(comment: post.comments[index],
      
      ),
    );
  }
}
