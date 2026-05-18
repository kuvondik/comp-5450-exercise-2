import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/presentation/splash/view/splash_page.dart';
import 'package:memory_match/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/get_it_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await setUpTestDependencies();
  });

  tearDown(tearDownTestDependencies);

  testWidgets('MyApp boots and renders the splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text('Memory Match'), findsWidgets);

    // Drain the 3-second splash transition timer so the test framework
    // doesn't complain about pending timers on teardown.
    await tester.pump(const Duration(seconds: 4));
  });
}
