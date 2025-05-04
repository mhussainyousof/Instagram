import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/post/domain/entity/comment.dart';
import 'package:instagram/features/post/domain/entity/post.dart';
import 'package:instagram/features/post/domain/repo/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final firestore = FirebaseFirestore.instance;

  final CollectionReference postCollection = FirebaseFirestore.instance
      .collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await postCollection.doc(postId).delete();
    } catch (e) {
      throw Exception("Error deleting post: $e");
    }
  }

  @override
Future<List<Post>> fetchAllPosts() async {
    try {
        // Get all posts with most recent posts at the top
        final postsSnapshot = await postCollection
            .orderBy('timestamp', descending: true)
            .get();

        // Convert each Firestore document from json -> list of posts
        final List<Post> allPosts = postsSnapshot.docs
            .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        return allPosts;
    } catch (e) {
        throw Exception("Error fetching posts: $e");
    }
}
  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      final snapshot =
          await postCollection.where('userId', isEqualTo: userId).get();
      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error fetching user posts: $e");
    }
  }
  
  @override
 Future<void> toggleLikePost(String postId, String userId) async {
  try {
    // Get the post document from Firestore
    final postDoc = await postCollection.doc(postId).get();

    if (postDoc.exists) {
      final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

      // Check if user has already liked this post
      final hasLiked = post.likes.contains(userId);

      // Update the likes list
      if (hasLiked) {
        post.likes.remove(userId); // Unlike
      } else {
        post.likes.add(userId); // Like
      }

      // Update the post document with the new like list
      await postCollection.doc(postId).update({
        'likes': post.likes,
      });
    } else {
      throw Exception("Post not found");
    }
  } catch (e) {
    throw Exception("Error toggling like: $e");
  }
}

  @override
Future<void> addComment(String postId, Comment comment) async {
  try {
    // get post document
    final postDoc = await postCollection.doc(postId).get();

    if (postDoc.exists) {
      // convert json object -> post
      final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

      // add the new comment
      post.comments.add(comment);

      // update the post document in firestore
      await postCollection.doc(postId).update({
        'comments': post.comments.map((comment) => comment.toJson()).toList(),
      });
    } else {
      throw Exception("Post not found");
    }
  } catch (e) {
    throw Exception("Error adding comment: $e");
  }
}

@override
Future<void> deleteComment(String postId, String commentId) async {
  try {
    final postDoc = await postCollection.doc(postId).get();

    if (postDoc.exists) {
      final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
      
      // remove comment by id
      post.comments.removeWhere((comment) => comment.id == commentId);
      
      await postCollection.doc(postId).update({
        'comments': post.comments.map((comment) => comment.toJson()).toList(),
      });
    } else {
      throw Exception("Post not found");
    }
  } catch (e) {
    throw Exception("Error deleting comment: $e");
  }
}
}
