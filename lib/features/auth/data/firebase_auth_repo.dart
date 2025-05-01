import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/domain/repo/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final firebaseAuth = FirebaseAuth.instance;
  @override
 Future<AppUser?> loginWithEmailPassword(String email, String password) async {
  try {
    //! attempt sign in
    UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    //! create user
    AppUser user = AppUser(
      uid: userCredential.user!.uid,
      email: email,
      name: '',
    );
    
    // return user
    return user;
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
   try {
    // attempt sign up
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(
          email: email, password: password);

    // create user
    AppUser user = AppUser(
      uid: userCredential.user!.uid, 
      email: email,
      name: name,
    );
    
    // return user
    return user;
  } catch (e) {
    throw Exception('Signup failed: $e');
  }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
Future<AppUser?> getCurrentUser() async {
  //! get current logged in user from firebase
  final firebaseUser = firebaseAuth.currentUser;

  //! no user logged in..
  if (firebaseUser == null) {
    return null;
  }

  //! user exists
  return AppUser(
    uid: firebaseUser.uid,
    email: firebaseUser.email ?? '', // Handle potential null email
    name: firebaseUser.displayName ?? '',
  );
}
}