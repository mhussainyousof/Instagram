import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/domain/repo/auth_repo.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  // check if user is already authenticated
  void checkAuth() async {
    emit(AuthLoading());
    try {
      final AppUser? user = await authRepo.getCurrentUser();

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated()); // Changed from Unauthorized to Unauthenticated
      }
    } catch (e) {
      emit(AuthError('Failed to check authentication: $e'));
    }
  }

  //! get current user
AppUser? get currentUser => _currentUser; 

//! login with email + pw
Future<void> login(String email, String pw) async {
  try {
    emit(AuthLoading());
    final user = await authRepo.loginWithEmailPassword(email, pw);

    if (user != null) {
      _currentUser = user;  
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  } catch (e) {
    emit(AuthError(e.toString()));
    emit(Unauthenticated());
  }
}

// register with email + pw
Future<void> register(String name, String email, String pw) async {
  try {
    emit(AuthLoading());
    final user = await authRepo.registerWithEmailPassword(name, email, pw);
    
    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  } catch (e) {
    emit(AuthError(e.toString()));
    emit(Unauthenticated());
  }
}

Future<void> logout()async{
authRepo.logout();
emit(Unauthenticated());
}

}