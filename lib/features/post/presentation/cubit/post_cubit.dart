import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/cloudanity/domain/storage_repo.dart';
import 'package:instagram/features/post/domain/entity/post.dart';
import 'package:instagram/features/post/domain/repo/post_repo.dart';
import 'package:instagram/features/post/presentation/cubit/post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  // Create a new post
  Future<void> createPost(Post post, {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    // Handle image upload for mobile p  latforms (using file path)
   
    try {
       if (imagePath != null) {
      emit(PostUploading());
      imageUrl = await storageRepo.uploadProfileImageMobile(imagePath, post.id);
    }
    // Handle image upload for web platforms (using file bytes)
    else if (imageBytes != null) {
      emit(PostUploading());
      imageUrl = await storageRepo.uploadProfileImageWeb(imageBytes, post.id);
    }

    // Update post with image URL if available
    final updatedPost = imageUrl != null ? post.copyWith(imageUrl: imageUrl) : post;

    postRepo.createPost(updatedPost);
    } catch (e) {
      emit(PostsError('Failed to create post : $e'));
    }
  }

     Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch posts: $e"));
    }
  }

  //! Delete a post
  Future<void> deletePost(String postId) async {
    try {
      emit(PostsLoading());
      await postRepo.deletePost(postId);
      final posts = await postRepo.fetchAllPosts(); // Refresh the list after deletion
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to delete post: $e"));
    }
  }

}