import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/profile/domain/repo/profile_repo.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(const ProfileInitial());

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

  //! Update bio and/or profile picture
  // Update bio and/or profile picture
Future<void> updateProfile({
  required String uid,
  String? newBio,
  String? newProfileImageUrl,
}) async {
  emit(const ProfileLoading());
  try {
    //! Fetch current profile first
    final currentUser = await profileRepo.fetchUserProfile(uid);
    
    //! Create updated profile with new values
    final updatedProfile = currentUser.copyWith(
      newBio: newBio,
      newProfileImageUrl: newProfileImageUrl,
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
}