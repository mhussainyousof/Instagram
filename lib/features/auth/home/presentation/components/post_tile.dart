import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/post/domain/entity/post.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';

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
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              postUser?.profileImageUrl != null
                  ? CachedNetworkImage(
                    imageUrl: postUser!.profileImageUrl,
                    errorWidget:
                        (context, url, error) => const Icon(Icons.person),
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
                  : const Icon(Icons.person),

              SizedBox(width: 10),
              // name
              Text(widget.post.userName, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),

              Spacer(),
              // delete button
              if(isOwnPost)
             GestureDetector(
              onTap: showOptions,
              child: Icon(Icons.delete, color: Colors.grey.shade600),
             )
            ],
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder:
                (context, url) =>
                    Container(height: 430, color: Colors.grey[200]),
            errorWidget:
                (context, url, error) => Container(
                  height: 430,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
          ),
          // Post caption and actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.post.text),
          ),
         // Buttons -> like, comment, timestamp
Row(
  children: [
    // Like button
    IconButton(
      icon: const Icon(Icons.favorite_border),
      onPressed: () {
        // Handle like action
      },
    ),
    const SizedBox(width: 8), // Add spacing between buttons
    
    // Comment button
    IconButton(
      icon: const Icon(Icons.comment),
      onPressed: () {
        // Handle comment action
      },
    ),
    const Spacer(), // Pushes timestamp to the right
    
    // Timestamp
    Text(
      widget.post.timestamp.toString(),
      style: Theme.of(context).textTheme.bodySmall,
    ),
  ],
), // Row
        ],
      ),
    );
  }
}






// class PostTile extends StatelessWidget {
//   final Post post;
//   final VoidCallback? onDelete;

//   const PostTile({super.key, required this.post, this.onDelete});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 // User info
//                 CircleAvatar(
//                   backgroundImage: NetworkImage(post.imageUrl),
//                   radius: 16,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(post.userName),
//                 const Spacer(),
//                 //! Delete button (only show if current user owns post)
//                 if (onDelete != null)
//                   IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed: onDelete,
//                   ),
//               ],
//             ),
//           ),
//           //! Post image
//           CachedNetworkImage(
//             imageUrl: post.imageUrl ,
//             height: 430,
//             width: double.infinity,
//             fit: BoxFit.cover,
//             placeholder: (context, url) => Container(
//               height: 430,
//               color: Colors.grey[200],
//             ),
//             errorWidget: (context, url, error) => Container(
//               height: 430,
//               color: Colors.grey[200],
//               child: const Icon(Icons.error),
//             ),
//           ),
//           // Post caption and actions
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(post.text),
//           ),
//         ],
//       ),
//     );
//   }
// }