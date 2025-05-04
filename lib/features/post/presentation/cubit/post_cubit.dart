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

  //! Create a new post
Future<void> createPost(Post post, {String? imagePath, Uint8List? imageBytes}) async {
  String? imageUrl;

  emit(PostUploading());

  try {
    //! Handle image upload for mobile platforms
    if (imagePath != null) {
      imageUrl = await storageRepo.uploadPostImageMobile(
        imagePath,
        "${post.id}_${DateTime.now().millisecondsSinceEpoch}",
      );
    }
    //! Handle image upload for web platforms
    else if (imageBytes != null) {
      imageUrl = await storageRepo.uploadPostImageWeb(
        imageBytes,
        "${post.id}_${DateTime.now().millisecondsSinceEpoch}",
      );
    }

    // Check if upload failed
    if ((imagePath != null || imageBytes != null) && imageUrl == null) {
      emit(PostsError("Failed to upload post image"));
      return;
    }

    //! Update post with image URL if available
    final updatedPost = imageUrl != null ? post.copyWith(imageUrl: imageUrl) : post;

    await postRepo.createPost(updatedPost);

    //! Refresh the post list (this will emit PostsLoaded inside)
    await fetchAllPosts();

  } catch (e) {
    emit(PostsError('Failed to create post: $e'));
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
      await postRepo.deletePost(postId);
      final posts = await postRepo.fetchAllPosts(); // Refresh the list after deletion
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to delete post: $e"));
    }
  }

// Toggle like on a post
Future<void> toggleLikePost(String postId, String userId) async {
  try {
    await postRepo.toggleLikePost(postId, userId);
  } catch (e) {
    emit(PostsError("Failed to toggle like: ${e.toString()}"));
    rethrow; 
  }
}

}