import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:uns/core/l10n/language.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/core/storage/settings_store.dart';

import '../../support/test_app.dart';

void main() {
  testWidgets('choosing Arabic switches the app to Arabic, right to left', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    container.read(appRouterProvider).go(Routes.language);
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(container.read(languageProvider), AppLanguage.ar);
    expect(find.text('اللغة'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('اللغة'))),
      TextDirection.rtl,
    );
    expect(
      container
          .read(settingsStoreProvider)
          .readJson(SettingKeys.language)?['id'],
      'ar',
    );

    // Back to following the phone (English in tests).
    await tester.tap(find.text('إعداد الهاتف'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Language'))),
      TextDirection.ltr,
    );
  });

  test('Arabic dates use Western digits and the Arabic comma', () async {
    await initializeDateFormatting('ar');
    useWesternDigits();
    final d = DateTime(2026, 9, 24, 11, 48);
    expect(DateFormat('h:mm', 'ar').format(d), '11:48');
    expect(
      DateFormat('EEEE${listComma('ar')} d MMMM', 'ar').format(d),
      'الخميس، 24 سبتمبر',
    );
  });
}
