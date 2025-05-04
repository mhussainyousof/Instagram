import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/cloudanity/domain/storage_repo.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/domain/repo/profile_repo.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_state.dart';

    class ProfileCubit extends Cubit<ProfileState> {
      final ProfileRepo profileRepo;
      //! final StorageRepo storageRepo;
      final StorageRepo storageRepo; 

      ProfileCubit({required this.profileRepo, required this.storageRepo})
        : super(const ProfileInitial());

      //! Fetch user profile using repo
      Future<void> fetchUserProfile(String uid) async {
        try {
          emit(const ProfileLoading());
          final user = await profileRepo.fetchUserProfile(uid);
          emit(ProfileLoaded(user));
        } catch (e) {
          emit(ProfileError(e.toString()));
        }
      }

      /// Fetches a user profile by their UID
/// Useful for loading multiple profiles (e.g., for posts in a feed)
Future<ProfileUser?> getUserProfile(String uid) async {
  try {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  } catch (e) {
    debugPrint('Error fetching user profile: $e');
    return null;
  }
}

      //! Update bio and/or profile picture
      // Update bio and/or profile picture
      Future<void> updateProfile({
        required String uid,
        String? newBio,
        // String? newProfileImageUrl,
        Uint8List? imageWebBytes,
        String? imageMobilePath,
      }) async {
        emit(const ProfileLoading());
        try {
          //! Fetch current profile first
          final currentUser = await profileRepo.fetchUserProfile(uid);

          // Profile picture update
          String? imageDownloadUrl;

          // Ensure there is an image
          if (imageWebBytes != null || imageMobilePath != null) {
            // For mobile
            if (imageMobilePath != null) {
              // Upload
              imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
                imageMobilePath,
                uid,
              );
            }
            // For web
            else if (imageWebBytes != null) {
              // Upload
              imageDownloadUrl = await storageRepo.uploadProfileImageWeb(
                imageWebBytes,
                uid,
              );
            }

            if (imageDownloadUrl == null) {
              emit(ProfileError("Failed to upload image"));
              return;
            }
          }

          //! Create updated profile with new values
          final updatedProfile = currentUser.copyWith(
            newBio: newBio ?? currentUser.bio,
            newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
          );

          //! Update in repository
          await profileRepo.updateProfile(updatedProfile);

          //! Emit the updated profile
          emit(ProfileLoaded(updatedProfile));
        } catch (e) {
          emit(ProfileError("Error updating profile: ${e.toString()}"));
          //! Optionally re-fetch the original profile
          await fetchUserProfile(uid);
        }
  }

  // Toggle follow/unfollow
Future<void> toggleFollow(String currentUserId, String targetUserId) async {
  try {
    // Call repository to toggle follow status
    await profileRepo.toggleFollow(currentUserId, targetUserId);
    
    // Refresh the profile data after follow status change
    await fetchUserProfile(targetUserId);
  } catch (e) {
    // Emit error state if something goes wrong
    emit(ProfileError("Error toggling follow: ${e.toString()}"));
  }
}
}
