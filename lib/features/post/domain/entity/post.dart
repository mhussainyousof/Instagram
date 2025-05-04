import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/post/domain/entity/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
    );
  }

  // Convert Post to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((commetn) => commetn.toString()).toList(),
    };
  }

  // Create Post from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    final List<Comment> comments =
        (json['comments'] as List<dynamic>?)
            ?.map((commentsJson) => Comment.fromJson(commentsJson))
            .toList() ??
        [];
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['name'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ?? []),
      comments: comments,
    );
  }
}
