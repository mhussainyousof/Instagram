import 'package:instagram/features/profile/domain/entity/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser> fetchUserProfile(String uid);
  Future<void> updateProfile(ProfileUser updatedProfile);
  Future<void> toggleFollow(String currentUid, String targetUid);

}