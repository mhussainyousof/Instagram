import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;

  const FollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: MaterialButton(
          onPressed: onPressed,
          padding: EdgeInsets.all(15),
          color: isFollowing
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).primaryColor,
          textColor: isFollowing
              ? Theme.of(context).colorScheme.onSecondaryContainer
              : Theme.of(context).colorScheme.onPrimary,
          child: Text(isFollowing ? "Following" : "Follow"),
        ),
      ),
    );
  }
}
