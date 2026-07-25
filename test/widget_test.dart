// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/main.dart';

void main() {
  testWidgets('smoke test renders activation screen', (WidgetTester tester) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DBHelper.initiateAllDB();
    await GetStorage.init();

    await tester.pumpWidget(const MyApp(appEnv: 'production'));
    await tester.pumpAndSettle();

    expect(find.text('Activate License'), findsOneWidget);
  });
}
