import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/domain/repo/profile_repo.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(const ProfileInitial());

  // Fetch user profile using repo
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
  Future<void> updateProfile({
    String? newBio,
    String? newProfileImageUrl,
    required ProfileUser currentUser,
  }) async {
    try {
      emit(const ProfileLoading());
      final updatedUser = currentUser.copyWith(
        newBio: newBio,
        newProfileImageUrl: newProfileImageUrl,
      );
      await profileRepo.updateProfile(updatedUser);
      emit(ProfileLoaded(updatedUser));
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
      emit(ProfileLoaded(currentUser));
    }
  }
}