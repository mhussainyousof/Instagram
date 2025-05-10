import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/cloudanity/domain/storage_repo.dart';
import 'package:instagram/features/post/domain/entity/comment.dart';
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

//! Toggle like on a post
Future<void> toggleLikePost(String postId, String userId) async {
  try {
    await postRepo.toggleLikePost(postId, userId);
  } catch (e) {
    emit(PostsError("Failed to toggle like: ${e.toString()}"));
    rethrow; 
  }
}

//! Add a comment to a post
Future<void> addComment(String postId, Comment comment) async {
  try {
    await postRepo.addComment(postId, comment);
    final currentState = state;
    
    if (currentState is PostsLoaded) {
      // Create a new list with updated post
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) {
          // Create a NEW post with updated comments
          return post.copyWith(
            comments: List<Comment>.from(post.comments)..add(comment),
          );
        }
        return post;
      }).toList();

      // Emit the new state with updated posts
      emit(PostsLoaded(updatedPosts));
    }
  } catch (e) {
    emit(PostsError("Failed to add comment: $e"));
  }
}

//! Delete comment from a post
Future<void> deleteComment(String postId, String commentId) async {
  try {
    await postRepo.deleteComment(postId, commentId);
    await fetchAllPosts();
  } catch (e) {
    emit(PostsError("Failed to delete comment: $e"));
  }
}

Future<void> toggleSave(Post post) async {
  try {
    // Immediately update the UI with the new saved state (optimistic update)
    final currentState = state;
    if (currentState is PostsLoaded) {
      final updatedPosts = currentState.posts.map((p) {
        if (p.id == post.id) {
          return p.copyWith(isSaved: !p.isSaved);
        }
        return p;
      }).toList();

      // Emit the updated state with the immediate UI update
      emit(PostsLoaded(updatedPosts));
    }

    // Perform the async operation (network request or database update)
    await postRepo.toggleSavePost(post.id, !post.isSaved);

    // If needed, you can do another update after the async operation if there's any additional state logic.
    // For example, if the save operation failed and you want to revert the state, you can do it here.

  } catch (e) {
    // If the operation fails, emit the error state
    emit(PostsError("Failed to toggle save: $e"));

    // Optionally, revert the optimistic update if there’s an error
    final currentState = state;
    if (currentState is PostsLoaded) {
      final updatedPosts = currentState.posts.map((p) {
        if (p.id == post.id) {
          return p.copyWith(isSaved: post.isSaved); // Revert back to original state
        }
        return p;
      }).toList();
      
      emit(PostsLoaded(updatedPosts)); // Emit the reverted state
    }
  }
}



}