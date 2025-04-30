import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/domain/repo/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    // TODO: implement loginWithEmailPassword
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    // TODO: implement registerWithEmailPassword
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }
}