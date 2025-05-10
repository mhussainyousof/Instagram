import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/post/domain/entity/comment.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/profile/presentation/pages/profile_page.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;

  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  AppUser? currentUser;
  bool isOwnComment = false;
  late final ProfileCubit profileCubit;
  ProfileUser? commentUser;

  @override
  void initState() {
    super.initState();
    profileCubit = context.read<ProfileCubit>();
    getCurrentUser();
    fetchCommentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnComment = (widget.comment.userId == currentUser?.uid);
  }

  void fetchCommentUser() async {
    try {
      final user = await profileCubit.getUserProfile(widget.comment.userId);
      if (user != null) {
        if (mounted) {
          setState(() {
            commentUser = user;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching comment user: $e');
    }
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<PostCubit>().deleteComment(
                    widget.comment.postId,
                    widget.comment.id,
                  );
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Avatar with CachedNetworkImage
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: widget.comment.userId),
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: commentUser?.profileImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: commentUser!.profileImageUrl,
                        placeholder: (context, url) => const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey,
                        ),
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      )
                    : const Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.grey,
                      ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and Text
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: widget.comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: widget.comment.text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Timestamp
                const SizedBox(height: 4),
                Text(
                  timeAgo(widget.comment.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Delete option (only for own comments)
          if (isOwnComment)
            IconButton(
              icon: const Icon(Icons.more_vert, size: 16),
              onPressed: showOptions,
            ),
        ],
      ),
    );
  }

  // Helper function to format timestamp
  String timeAgo(DateTime date) {
    // Implement your time ago logic here
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}