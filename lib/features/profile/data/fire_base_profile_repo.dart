import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/domain/repo/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser> fetchUserProfile(String uid) async {
    try {
      // Get user document from Firestore
      final userDoc = await firebaseFirestore.collection('users').doc(uid).get();

     if (userDoc.exists) {
  final userData = userDoc.data();
  
  if (userData != null) {
    // fetch followers & following
    final followers = List<String>.from(userData['followers'] ?? []);
    final following = List<String>.from(userData['following'] ?? []);

    return ProfileUser(
      uid: uid,
      email: userData['email'],
      name: userData['name'],
      bio: userData['bio'] ?? '',
      profileImageUrl: userData['profileImageUrl'].toString(),
      followers: followers,
      following: following,
    );
  }
}
      
      throw Exception('User not found');
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      await firebaseFirestore.collection('users').doc(updatedProfile.uid).update({
        'email': updatedProfile.email,
        'name': updatedProfile.name,
        'bio': updatedProfile.bio,
        'profileImageUrl': updatedProfile.profileImageUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
  try {
    final currentUserDoc = 
        await firebaseFirestore.collection('users').doc(currentUid).get();
    final targetUserDoc = 
        await firebaseFirestore.collection('users').doc(targetUid).get();

    if (currentUserDoc.exists && targetUserDoc.exists) {
      final currentUserData = currentUserDoc.data();
      final targetUserData = targetUserDoc.data();

      if (currentUserData != null && targetUserData != null) {
        final List<String> currentFollowing =
            List<String>.from(currentUserData['following'] ?? []);
        final List<String> targetFollowers =
            List<String>.from(targetUserData['followers'] ?? []);

        // Check if current user is already following target user
        if (currentFollowing.contains(targetUid)) {
          // Unfollow logic
          await Future.wait([
            // Remove targetUid from current user's following
            firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayRemove([targetUid])
            }),
            // Remove currentUid from target user's followers
            firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayRemove([currentUid])
            }),
          ]);
        } else {
          // Follow logic
          await Future.wait([
            // Add targetUid to current user's following
            firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayUnion([targetUid])
            }),
            // Add currentUid to target user's followers
            firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayUnion([currentUid])
            }),
          ]);
        }
      }
    }
  } catch (e) {
    print('Error toggling follow status: $e');
    rethrow;
  }
}
}