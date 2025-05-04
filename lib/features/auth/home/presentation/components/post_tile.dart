import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/features/post/domain/entity/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback? onDelete;

  const PostTile({super.key, required this.post, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // User info
                CircleAvatar(
                  backgroundImage: NetworkImage(post.imageUrl),
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Text(post.userName),
                const Spacer(),
                //! Delete button (only show if current user owns post)
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
          //! Post image
          CachedNetworkImage(
            imageUrl: post.imageUrl ,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 430,
              color: Colors.grey[200],
            ),
            errorWidget: (context, url, error) => Container(
              height: 430,
              color: Colors.grey[200],
              child: const Icon(Icons.error),
            ),
          ),
          // Post caption and actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.text),
          ),
        ],
      ),
    );
  }
}