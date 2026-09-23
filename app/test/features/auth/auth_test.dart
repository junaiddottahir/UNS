import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';

import '../../support/test_app.dart';

Future<ProviderContainer> _profile(
  WidgetTester tester, {
  required FakeAuth auth,
  FakeAccountApi? api,
}) async {
  final container = await pumpApp(tester, auth: auth, accountApi: api);
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.profile);
  await tester.pumpAndSettle();
  return container;
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).first, text);
  await tester.pump();
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Next'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('create an account: email → password → code → saved', (
    tester,
  ) async {
    final auth = FakeAuth();
    await _profile(tester, auth: auth);
    expect(find.text('Save your journey'), findsOneWidget);
    expect(find.text('Sync your settings across devices'), findsOneWidget);

    await tester.tap(find.text('Save your journey'));
    await tester.pumpAndSettle();
    expect(find.textContaining('journal always stays on this phone'), findsOne);
    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();

    await _type(tester, 'not-an-email');
    await tester.tap(find.bySemanticsLabel('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your email'), findsOneWidget); // arrow stays off

    await _type(tester, 'amina@example.com');
    await _next(tester);
    expect(find.text('Create a password'), findsOneWidget);
    await _type(tester, 'short');
    expect(find.text('8 or more characters'), findsOneWidget);
    await _type(tester, 'long enough pw');
    await _next(tester);

    expect(find.text('Enter the code'), findsOneWidget);
    expect(find.text('Sent to amina@example.com'), findsOneWidget);
    await _type(tester, '000000');
    await tester.pumpAndSettle();
    expect(find.textContaining("isn't right"), findsOneWidget);
    await _type(tester, '123456');
    await tester.pumpAndSettle();

    expect(find.text('Journey saved'), findsWidgets);
    expect(find.text('Signed in with amina@example.com'), findsOneWidget);
    expect(auth.confirmed, {'amina@example.com'});
  });

  testWidgets('an email that is taken says so', (tester) async {
    final auth = FakeAuth()..users['amina@example.com'] = 'x';
    await _profile(tester, auth: auth);
    await tester.tap(find.text('Save your journey'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();
    await _type(tester, 'amina@example.com');
    await _next(tester);
    await _type(tester, 'long enough pw');
    await _next(tester);
    expect(find.textContaining('already an account'), findsOneWidget);
  });

  testWidgets('sign in, wrong then right password', (tester) async {
    final auth = FakeAuth()..users['amina@example.com'] = 'correct horse';
    await _profile(tester, auth: auth);
    await tester.tap(find.text('Save your journey'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();
    await _type(tester, 'amina@example.com');
    await _next(tester);
    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await _type(tester, 'wrong');
    await _next(tester);
    expect(find.textContaining("don't match"), findsOneWidget);
    await _type(tester, 'correct horse');
    await _next(tester);
    expect(find.text('Signed in with amina@example.com'), findsOneWidget);
  });

  testWidgets('forgot password: code, then a new password', (tester) async {
    final auth = FakeAuth()..users['amina@example.com'] = 'old password';
    await _profile(tester, auth: auth);
    await tester.tap(find.text('Save your journey'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();
    await _type(tester, 'amina@example.com');
    await _next(tester);
    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(auth.resets, ['amina@example.com']);
    await _type(tester, '123456');
    await tester.pumpAndSettle();
    expect(find.text('Choose a new password'), findsOneWidget);
    await _type(tester, 'brand new password');
    await _next(tester);
    expect(find.text('Password updated'), findsOneWidget);
    expect(auth.users['amina@example.com'], 'brand new password');
  });

  testWidgets('sign out and delete account', (tester) async {
    final auth = FakeAuth()..users['a@example.com'] = 'password1';
    await auth.signIn('a@example.com', 'password1');
    final api = FakeAccountApi();
    await _profile(tester, auth: auth, api: api);

    await tester.tap(find.text('Journey saved'));
    await tester.pumpAndSettle();
    expect(find.text('a@example.com'), findsOneWidget);
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('journal and everything else'), findsOne);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(api.calls, ['DELETE /v1/me']);
    expect(find.text('Account deleted'), findsOneWidget);
    expect(find.text('Save your journey'), findsOneWidget);
    expect(auth.current, isNull);
  });

  testWidgets('a failed delete keeps the account and says so', (tester) async {
    final auth = FakeAuth()..users['a@example.com'] = 'password1';
    await auth.signIn('a@example.com', 'password1');
    await _profile(tester, auth: auth, api: FakeAccountApi(fails: true));
    await tester.tap(find.text('Journey saved'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Couldn't delete"), findsOneWidget);
    expect(auth.current, isNotNull);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Signed out'), findsOneWidget);
    expect(auth.current, isNull);
  });

  testWidgets('no accounts configured: no account card', (tester) async {
    final container = await pumpApp(tester);
    container.read(appRouterProvider).go(Routes.profile);
    await tester.pumpAndSettle();
    expect(find.text('Save your journey'), findsNothing);
    expect(find.text('Privacy'), findsOneWidget);
  });

  testWidgets('offered once after onboarding, with Not now', (tester) async {
    final container = await pumpApp(tester, auth: FakeAuth());
    container
        .read(userLocationProvider.notifier)
        .set(UserLocation.fromCity(sydney));
    container.read(appRouterProvider).go(Routes.reciterStep);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Save your journey'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('NEXT PRAYER'), findsOneWidget);
  });
}
