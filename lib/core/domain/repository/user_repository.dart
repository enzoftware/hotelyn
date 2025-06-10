sealed class LoginException implements Exception {}

class WrongPasswordException extends LoginException {}

class UserNotFoundException extends LoginException {}

class UserRepository {
  UserRepository();

  /// Login s
  Future<String?> login(String email, String password) async {
    return null;
  }

  Future<void> logout() async {}
}
