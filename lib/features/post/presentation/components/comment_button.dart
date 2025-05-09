import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CommentButton extends StatelessWidget {
  final int commentCount;
  final VoidCallback onTap;

  const CommentButton({
    super.key,
    required this.commentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              
              Iconsax.message_favorite, 
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            const SizedBox(width: 4),
            Text(
              commentCount.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}