import 'package:hotelyn_domain/src/auth_session.dart';
import 'package:hotelyn_domain/src/user.dart';

/// Authentication: guest email-OTP sign-in and staff password login.
///
/// A shared-vocabulary contract implemented by the service layer (BE-902).
/// Domain types only.
abstract class AuthRepository {
  /// Requests an email OTP for [email] (guest sign-in). Completes once the code
  /// is on its way.
  Future<void> requestEmailOtp({required String email});

  /// Verifies the [token] a guest received for [email], returning the
  /// authenticated [AuthSession].
  Future<AuthSession> verifyEmailOtp({
    required String email,
    required String token,
  });

  /// Signs a staff member in with [email] and [password], returning the
  /// authenticated [AuthSession].
  Future<AuthSession> signInWithPassword({
    required String email,
    required String password,
  });

  /// The [User] the [accessToken] belongs to, or `null` if it is not valid.
  Future<User?> currentUser(String accessToken);
}
