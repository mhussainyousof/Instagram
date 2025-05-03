import 'package:cloud_firestore/cloud_firestore.dart';
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
}
