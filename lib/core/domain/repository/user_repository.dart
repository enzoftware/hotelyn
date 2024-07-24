import 'package:firebase_auth/firebase_auth.dart';

sealed class LoginException implements Exception {}

class WrongPasswordException extends LoginException {}

class UserNotFounddException extends LoginException {}

class UserRepository {
  UserRepository({
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<String?> login(String email, String password) async {
    try {
      final response = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return response.credential?.accessToken;
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'invalid-email':
          throw WrongPasswordException();
        case 'user-not-found':
          throw UserNotFounddException();
        default:
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
