import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/config/app_config.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../core/widgets/toast.dart';
import '../../l10n/app_localizations.dart';
import 'auth_flow.dart';
import 'auth_layout.dart';

/// Signed in: back to where the flow started, with a toast.
void _finishSignIn(BuildContext context, WidgetRef ref, String message) {
  context.go(ref.read(authFlowProvider).returnTo ?? Routes.profile);
  showToast(message);
}

/// Runs an auth step, turning failures into a message for the screen.
Future<String?> _attempt(
  AppLocalizations l10n,
  Future<void> Function() step,
) async {
  try {
    await step();
    return null;
  } on AuthFailure catch (e) {
    return l10n.authProblem(e.problem);
  }
}

/// "Save your journey": Apple / Google (once configured) or email.
/// Offered once after onboarding and from the Profile account card.
class SaveJourneyScreen extends ConsumerWidget {
  const SaveJourneyScreen({super.key, this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final apple = AppConfig.appleSignInEnabled && Platform.isIOS;
    const google = AppConfig.googleSignInEnabled;
    void email() {
      ref.read(authFlowProvider.notifier).begin(returnTo: returnTo);
      context.push(Routes.accountEmail);
    }

    return Scaffold(
      body: AmbientBackground(
        fade: BackgroundFade.bottom,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextLink(
                    label: l10n.notNow,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(Routes.home),
                  ),
                ),
              ),
              const Spacer(),
              SvgPicture.asset('assets/images/logo.svg', width: 72, height: 72),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.screenBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.saveYourJourney, style: AppText.headline),
                    const SizedBox(height: 14),
                    Text(l10n.saveJourneyBody, style: AppText.body),
                    const SizedBox(height: 28),
                    // Apple and Google need developer accounts first; until
                    // then email is the way in (progress-tracker.md).
                    if (apple) ...[
                      PrimaryButton(
                        label: l10n.continueWithApple,
                        onPressed: null,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (google) ...[
                      _GlassWide(label: l10n.continueWithGoogle, onTap: null),
                      const SizedBox(height: 10),
                    ],
                    if (apple || google)
                      _GlassWide(label: l10n.continueWithEmail, onTap: email)
                    else
                      PrimaryButton(
                        label: l10n.continueWithEmail,
                        icon: Icons.mail_outline,
                        onPressed: email,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassWide extends StatelessWidget {
  const _GlassWide({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.glassFill,
          side: const BorderSide(color: AppColors.glassEdge),
          shape: const StadiumBorder(),
          textStyle: AppText.button,
        ),
        child: Text(label),
      ),
    );
  }
}

/// "Your email".
class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  late final _email = TextEditingController(
    text: ref.read(authFlowProvider).email,
  )..addListener(() => setState(() {}));

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _next() {
    if (!isEmail(_email.text)) return;
    ref.read(authFlowProvider.notifier).setEmail(_email.text);
    context.push(Routes.accountPassword);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthStep(
      title: l10n.yourEmail,
      field: AuthField(
        controller: _email,
        hint: l10n.emailHint,
        keyboard: TextInputType.emailAddress,
        autofill: const [AutofillHints.email],
        onSubmitted: _next,
      ),
      canGo: isEmail(_email.text),
      busy: false,
      onGo: _next,
      goLabel: l10n.next,
    );
  }
}

/// "Create a password" for a new account, or "Welcome back" to sign in.
class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final l10n = AppLocalizations.of(context);
    final flow = ref.read(authFlowProvider);
    final auth = ref.read(authServiceProvider);
    setState(() => _busy = true);
    final error = await _attempt(
      l10n,
      () => flow.newAccount
          ? auth.signUp(flow.email, _password.text)
          : auth.signIn(flow.email, _password.text),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error != null) return;
    if (flow.newAccount) {
      context.push('${Routes.accountCode}?purpose=signup');
    } else {
      _finishSignIn(context, ref, l10n.welcomeBack);
    }
  }

  Future<void> _forgot() async {
    final l10n = AppLocalizations.of(context);
    final email = ref.read(authFlowProvider).email;
    setState(() => _busy = true);
    final error = await _attempt(
      l10n,
      () => ref.read(authServiceProvider).sendPasswordReset(email),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) context.push('${Routes.accountCode}?purpose=recovery');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final flow = ref.watch(authFlowProvider);
    final newAccount = flow.newAccount;
    final ok = _password.text.length >= minPasswordLength || !newAccount;
    return AuthStep(
      title: newAccount ? l10n.createPassword : l10n.welcomeBack,
      subtitle: newAccount ? null : flow.email,
      field: AuthField(
        controller: _password,
        hint: newAccount ? '••••••••' : l10n.passwordHint,
        obscure: true,
        autofill: [
          newAccount ? AutofillHints.newPassword : AutofillHints.password,
        ],
        onSubmitted: ok && _password.text.isNotEmpty ? _go : null,
      ),
      hint: newAccount ? l10n.passwordRule : null,
      error: _error,
      links: [
        if (!newAccount)
          TextLink(
            label: l10n.forgotPassword,
            onPressed: _busy ? null : _forgot,
          ),
        TextLink(
          label: newAccount ? l10n.haveAccount : l10n.newHere,
          onPressed: () {
            ref.read(authFlowProvider.notifier).setNewAccount(!newAccount);
            setState(() => _error = null);
          },
        ),
      ],
      canGo: ok && _password.text.isNotEmpty,
      busy: _busy,
      onGo: _go,
      goLabel: l10n.next,
    );
  }
}

/// "Enter the code": the 6 digits emailed to confirm a new account or to
/// reset a password.
class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({super.key, required this.recovery});

  final bool recovery;

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  static const resendAfter = 30;
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;
  int _wait = resendAfter;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _code.addListener(_onCode);
    _startWait();
  }

  void _startWait() {
    _wait = resendAfter;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _wait--);
      if (_wait <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _onCode() {
    if (_code.text.isNotEmpty) setState(() => _error = null);
    if (_code.text.length == 6 && !_busy) _verify();
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    final email = ref.read(authFlowProvider).email;
    final auth = ref.read(authServiceProvider);
    setState(() => _busy = true);
    final error = await _attempt(
      l10n,
      () => widget.recovery
          ? auth.confirmPasswordReset(email, _code.text)
          : auth.confirmSignUp(email, _code.text),
    );
    if (!mounted) return;
    // Clear the boxes first: clearing counts as typing and would otherwise
    // wipe the message straight away.
    if (error != null) _code.clear();
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error != null) return;
    if (widget.recovery) {
      context.pushReplacement(Routes.accountNewPassword);
    } else {
      _finishSignIn(context, ref, l10n.journeySaved);
    }
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    final flow = ref.read(authFlowProvider);
    final auth = ref.read(authServiceProvider);
    final error = await _attempt(
      l10n,
      () => widget.recovery
          ? auth.sendPasswordReset(flow.email)
          : auth.resendSignUpCode(flow.email),
    );
    if (!mounted) return;
    if (error == null) {
      showToast(l10n.codeResent);
      _startWait();
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(authFlowProvider).email;
    final digits = _code.text;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const BackTopBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    40,
                    AppSpacing.screenH,
                    AppSpacing.screenBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.enterCode, style: AppText.title2),
                      const SizedBox(height: 12),
                      Text(l10n.codeSentTo(email), style: AppText.body),
                      const SizedBox(height: 40),
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (var i = 0; i < 6; i++)
                                Container(
                                  width: 46,
                                  height: 58,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.glassFill,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: i == digits.length
                                          ? AppColors.textPrimary
                                          : AppColors.glassEdge,
                                    ),
                                  ),
                                  child: Text(
                                    i < digits.length ? digits[i] : '',
                                    style: AppText.input,
                                  ),
                                ),
                            ],
                          ),
                          // An invisible field takes the typing (and the
                          // code the keyboard offers from the email).
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0,
                              child: TextField(
                                controller: _code,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode,
                                ],
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _error!,
                          style: AppText.body.copyWith(
                            fontSize: 13,
                            color: AppColors.accentPrimary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Center(
                        child: _busy
                            ? const CircularProgressIndicator(
                                color: AppColors.textSubtle,
                              )
                            : _wait > 0
                            ? Text(
                                l10n.resendIn(
                                  '0:${_wait.toString().padLeft(2, '0')}',
                                ),
                                style: AppText.link.copyWith(
                                  color: AppColors.textFaint,
                                ),
                              )
                            : TextLink(
                                label: l10n.resendCode,
                                onPressed: _resend,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// After a reset code: "Choose a new password".
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final error = await _attempt(
      l10n,
      () => ref.read(authServiceProvider).setNewPassword(_password.text),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) _finishSignIn(context, ref, l10n.passwordUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ok = _password.text.length >= minPasswordLength;
    return AuthStep(
      title: l10n.newPassword,
      field: AuthField(
        controller: _password,
        hint: '••••••••',
        obscure: true,
        autofill: const [AutofillHints.newPassword],
        onSubmitted: ok ? _go : null,
      ),
      hint: l10n.passwordRule,
      error: _error,
      canGo: ok,
      busy: _busy,
      onGo: _go,
      goLabel: l10n.next,
    );
  }
}

/// The signed-in account: who, sign out, and delete account.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _busy = false;

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(authServiceProvider).signOut();
    if (!mounted) return;
    context.go(Routes.profile);
    showToast(l10n.signedOut);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentPrimary,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(accountApiProvider).deleteAccount();
    } on ApiException {
      if (!mounted) return;
      setState(() => _busy = false);
      showToast(l10n.deleteFailed);
      return;
    }
    // The account is gone on the server; drop the local session too.
    await ref.read(authServiceProvider).signOut();
    if (!mounted) return;
    context.go(Routes.profile);
    showToast(l10n.accountDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(accountProvider).value;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const BackTopBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  22,
                  AppSpacing.screenH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.account, style: AppText.title2),
                    const SizedBox(height: 12),
                    Text(account?.email ?? '', style: AppText.body),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 40),
                child: GlassCard(
                  child: Column(
                    children: [
                      GlassRow(
                        leading: Icons.logout,
                        label: Text(l10n.signOut),
                        onTap: _busy ? null : _signOut,
                      ),
                      GlassRow(
                        leading: Icons.delete_outline,
                        label: Text(
                          l10n.deleteAccount,
                          style: const TextStyle(
                            color: AppColors.accentPrimary,
                          ),
                        ),
                        divider: false,
                        onTap: _busy ? null : _delete,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
