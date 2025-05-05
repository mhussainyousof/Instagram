import 'package:instagram/features/profile/domain/entity/profile_user.dart';

/// Profile Screen States
/// 
/// Represents different states of the profile screen
abstract class ProfileState {
  const ProfileState();
}

/// Initial state - when the profile screen first loads
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

//! Loading state - when profile data is being fetched
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

//! Loaded state - when profile data is successfully loaded
/// 
//! Contains the loaded [ProfileUser] data
class ProfileLoaded extends ProfileState {
  final ProfileUser user;
  
  const ProfileLoaded(this.user);
}

/// Contains an error [message] describing what went wrong
class ProfileError extends ProfileState {
  final String message;
  
  const ProfileError(this.message);
}