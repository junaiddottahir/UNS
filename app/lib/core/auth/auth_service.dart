import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../config/app_config.dart';

/// The signed-in account (accounts are optional; null when signed out).
class Account {
  const Account({
    required this.id,
    required this.email,
    required this.provider,
  });
  final String id;
  final String? email;

  /// `email`, `apple` or `google`.
  final String provider;
}

/// Why an auth step didn't work, for a friendly message.
enum AuthProblem {
  wrongPassword,
  emailTaken,
  weakPassword,
  wrongCode,
  tooManyTries,
  offline,
  notAvailable,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.problem);
  final AuthProblem problem;
}

/// Sign-in with Supabase Auth. An interface so tests can fake it.
abstract interface class AuthService {
  bool get available;
  Account? get current;
  Stream<Account?> get changes;

  /// The current access token for the Uns backend, refreshed if needed.
  Future<String?> accessToken();

  /// Creates the account; a 6-digit code is emailed to confirm it.
  Future<void> signUp(String email, String password);
  Future<void> confirmSignUp(String email, String code);

  /// Emails a fresh sign-up code.
  Future<void> resendSignUpCode(String email);
  Future<void> signIn(String email, String password);

  /// Emails a 6-digit code to reset the password.
  Future<void> sendPasswordReset(String email);
  Future<void> confirmPasswordReset(String email, String code);
  Future<void> setNewPassword(String password);

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._auth);

  final sb.GoTrueClient _auth;

  @override
  bool get available => true;

  static Account? _account(sb.User? u) => u == null
      ? null
      : Account(
          id: u.id,
          email: u.email,
          provider: u.appMetadata['provider'] as String? ?? 'email',
        );

  @override
  Account? get current => _account(_auth.currentUser);

  @override
  Stream<Account?> get changes =>
      _auth.onAuthStateChange.map((s) => _account(s.session?.user));

  @override
  Future<String?> accessToken() async {
    final session = _auth.currentSession;
    if (session == null) return null;
    if (session.isExpired) {
      try {
        return (await _auth.refreshSession()).session?.accessToken;
      } on Exception {
        return null;
      }
    }
    return session.accessToken;
  }

  Future<T> _run<T>(Future<T> Function() step) async {
    try {
      return await step();
    } on AuthFailure {
      rethrow; // already specific (e.g. email taken)
    } on sb.AuthException catch (e) {
      throw AuthFailure(_problem(e));
    } on Exception {
      throw const AuthFailure(AuthProblem.offline);
    }
  }

  static AuthProblem _problem(sb.AuthException e) {
    final code = e.code ?? '';
    final text = e.message.toLowerCase();
    if (code == 'invalid_credentials') return AuthProblem.wrongPassword;
    if (code == 'user_already_exists' || code == 'email_exists') {
      return AuthProblem.emailTaken;
    }
    if (code == 'weak_password') return AuthProblem.weakPassword;
    if (code == 'otp_expired' || text.contains('token')) {
      return AuthProblem.wrongCode;
    }
    if (e.statusCode == '429' || code.contains('rate_limit')) {
      return AuthProblem.tooManyTries;
    }
    return AuthProblem.unknown;
  }

  @override
  Future<void> signUp(String email, String password) => _run(() async {
    final r = await _auth.signUp(email: email, password: password);
    // Supabase hides whether an email exists: an existing one comes back
    // with no identities.
    if (r.user != null && (r.user!.identities ?? const []).isEmpty) {
      throw const AuthFailure(AuthProblem.emailTaken);
    }
  });

  @override
  Future<void> confirmSignUp(String email, String code) => _run(
    () => _auth.verifyOTP(email: email, token: code, type: sb.OtpType.signup),
  );

  @override
  Future<void> resendSignUpCode(String email) =>
      _run(() => _auth.resend(type: sb.OtpType.signup, email: email));

  @override
  Future<void> signIn(String email, String password) =>
      _run(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<void> sendPasswordReset(String email) =>
      _run(() => _auth.resetPasswordForEmail(email));

  @override
  Future<void> confirmPasswordReset(String email, String code) => _run(
    () => _auth.verifyOTP(email: email, token: code, type: sb.OtpType.recovery),
  );

  @override
  Future<void> setNewPassword(String password) =>
      _run(() => _auth.updateUser(sb.UserAttributes(password: password)));

  @override
  Future<void> signOut() => _run(() => _auth.signOut());
}

/// Used when Supabase isn't configured: accounts are simply unavailable.
class NoAuthService implements AuthService {
  const NoAuthService();

  @override
  bool get available => false;
  @override
  Account? get current => null;
  @override
  Stream<Account?> get changes => const Stream.empty();
  @override
  Future<String?> accessToken() async => null;

  Never _no() => throw const AuthFailure(AuthProblem.notAvailable);

  @override
  Future<void> signUp(String email, String password) async => _no();
  @override
  Future<void> confirmSignUp(String email, String code) async => _no();
  @override
  Future<void> resendSignUpCode(String email) async => _no();
  @override
  Future<void> signIn(String email, String password) async => _no();
  @override
  Future<void> sendPasswordReset(String email) async => _no();
  @override
  Future<void> confirmPasswordReset(String email, String code) async => _no();
  @override
  Future<void> setNewPassword(String password) async => _no();
  @override
  Future<void> signOut() async {}
}

final authServiceProvider = Provider<AuthService>((ref) {
  if (AppConfig.supabaseUrl.isEmpty) return const NoAuthService();
  return SupabaseAuthService(sb.Supabase.instance.client.auth);
});

/// The signed-in account, kept current.
final accountProvider = StreamProvider<Account?>((ref) async* {
  final auth = ref.watch(authServiceProvider);
  yield auth.current;
  yield* auth.changes;
});
