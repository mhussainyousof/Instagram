import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/post/domain/entity/comment.dart';
import 'package:instagram/features/post/domain/entity/post.dart';
import 'package:instagram/features/post/presentation/components/comment_button.dart';
import 'package:instagram/features/post/presentation/components/comment_sheet.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/post/presentation/cubit/post_state.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/profile/presentation/pages/profile_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // Inside a StatefulWidget's state class

  // Cubits
  late final PostCubit postCubit;
  late final ProfileCubit profileCubit;

  bool isOwnPost = false;

  // Current user
  AppUser? currentUser;

  // Post user
  ProfileUser? postUser;

  // On startup
  @override
  void initState() {
    super.initState();
    postCubit = context.read<PostCubit>();
    profileCubit = context.read<ProfileCubit>();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser?.uid);
  }

  void fetchPostUser() async {
    try {
      final user = await profileCubit.getUserProfile(widget.post.userId);
      if (user != null) {
        setState(() {
          postUser = user;
        });
      }
    } catch (e) {
      debugPrint('Error fetching post user: $e');
    }
  }

  // user tapped like button
  void toggleLikePost() {
    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // optimistically like & update UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    // update like
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      // if there's an error, revert back to original values
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  // comment text controller
  final commentTextController = TextEditingController();

  // open comment box -> user wants to type a new comment

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(post: widget.post),
    );
  }

  void addComment() {
    // create a new comment
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    ); // Comment

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
      commentTextController.clear();
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  // show options for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDeletePressed!.call();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                
                MaterialPageRoute(
                  builder: (context) => ProfilePage(uid: widget.post.userId),
                ),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                postUser?.profileImageUrl != null
                    ? CachedNetworkImage(
                      imageUrl: postUser!.profileImageUrl,
                      errorWidget:
                          (context, url, error) =>
                              const Icon(Iconsax.user_minus),
                      imageBuilder:
                          (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    )
                    : const Icon(Iconsax.user),

                SizedBox(width: 10),
                // name
                Column(
                  children: [
                    Text(
                      widget.post.userName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    // Timestamp
                    Text(
                      timeago.format(widget.post.timestamp, locale: 'en_short'),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),

                Spacer(),
                //! delete button
                if (isOwnPost)
                  GestureDetector(
                    onTap: showOptions,
                    child: Icon(
                      Iconsax.trash,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        //! Post caption and actions
        Padding(
          padding: const EdgeInsets.only(left: 7),
          child: Text(widget.post.text),
        ),
        CachedNetworkImage(
          imageUrl: widget.post.imageUrl,
          height: 430,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(height: 430, color: Colors.grey[200]),
          errorWidget:
              (context, url, error) => Container(
                height: 430,
                color: Colors.grey[200],
                child: Icon(Iconsax.warning_2, size: 40, color: Colors.red),
              ),
        ),

        //! Buttons -> like, comment, timestamp
        Padding(
          padding: const EdgeInsets.only(
            bottom: 20,
            left: 12,
            top: 10,
            right: 10,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Row(
                  children: [
                    // like button
                    GestureDetector(
                      onTap: toggleLikePost,
                      child: Icon(
                        widget.post.likes.contains(currentUser!.uid)
                            ? Iconsax.heart_search1
                            : Iconsax.heart,
                        size: 35,
                        color:
                            widget.post.likes.contains(currentUser!.uid)
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.post.likes.length.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // comment button
              BlocBuilder<PostCubit, PostState>(
                builder: (context, state) {
                  if (state is PostsLoaded) {
                    //! final individual post
                    final post = state.posts.firstWhere(
                      (post) => post.id == widget.post.id,
                    );

                    if (post.comments.isNotEmpty) {
                      return CommentButton(
                        commentCount: widget.post.comments.length,
                        onTap: () => _showCommentSheet(context),
                      );
                    }
                  }

                  if (state is PostsLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is PostsError) {
                    return Center(child: Text(state.message));
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  context.read<PostCubit>().toggleSave(widget.post);
                },
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    widget.post.isSaved ? Iconsax.bookmark : Iconsax.bookmark_2,
                    key: ValueKey<bool>(widget.post.isSaved),
                    size: 30,
                    color:
                        widget.post.isSaved
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
