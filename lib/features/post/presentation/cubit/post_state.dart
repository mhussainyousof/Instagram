
import 'package:instagram/features/post/domain/entity/post.dart';

abstract class PostState {}

//! Initial state when the posts are not yet loaded
class PostsInitial extends PostState {}

//! Loading state when fetching posts
class PostsLoading extends PostState {}

//! Uploading state when creating a new post
class PostUploading extends PostState {}

//! Error state with error message
class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}

//! Loaded state with list of posts
class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}