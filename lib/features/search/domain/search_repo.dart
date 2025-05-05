import 'package:instagram/features/profile/domain/entity/profile_user.dart';

abstract class SearchRepo{
  Future<List<ProfileUser?>> searchUsers(String query);
}