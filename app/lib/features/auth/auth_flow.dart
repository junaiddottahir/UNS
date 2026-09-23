import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';
import '../../l10n/app_localizations.dart';

/// Where the email flow is: the email being used, whether this is a new
/// account, and where to go when done.
class AuthFlow {
  const AuthFlow({this.email = '', this.newAccount = true, this.returnTo});
  final String email;
  final bool newAccount;

  /// Route to return to after signing in; null returns to Profile.
  final String? returnTo;

  AuthFlow copyWith({String? email, bool? newAccount}) => AuthFlow(
    email: email ?? this.email,
    newAccount: newAccount ?? this.newAccount,
    returnTo: returnTo,
  );
}

final authFlowProvider = NotifierProvider<AuthFlowNotifier, AuthFlow>(
  AuthFlowNotifier.new,
);

class AuthFlowNotifier extends Notifier<AuthFlow> {
  @override
  AuthFlow build() => const AuthFlow();

  void begin({String? returnTo}) => state = AuthFlow(returnTo: returnTo);
  void setEmail(String email) => state = state.copyWith(email: email.trim());
  void setNewAccount(bool value) => state = state.copyWith(newAccount: value);
}

bool isEmail(String s) => RegExp(r'^\S+@\S+\.\S+$').hasMatch(s.trim());

const minPasswordLength = 8;

extension AuthMessages on AppLocalizations {
  String authProblem(AuthProblem p) => switch (p) {
    AuthProblem.wrongPassword => authWrongPassword,
    AuthProblem.emailTaken => authEmailTaken,
    AuthProblem.weakPassword => authWeakPassword,
    AuthProblem.wrongCode => authWrongCode,
    AuthProblem.tooManyTries => authTooManyTries,
    AuthProblem.offline => authOffline,
    AuthProblem.notAvailable => authNotAvailable,
    AuthProblem.unknown => authUnknown,
  };
}
