import 'package:get_it/get_it.dart';
import 'package:memory_match/layers/presentation/injector.dart';

/// Initializes the real GetIt graph for tests that exercise full pages.
///
/// Callers must call `SharedPreferences.setMockInitialValues({})` before this
/// (LocalStorageImpl pulls the instance during initGetIt).
Future<void> setUpTestDependencies() async {
  await GetIt.instance.reset();
  await initGetIt();
}

/// Resets the GetIt instance so tests do not leak singletons between cases.
Future<void> tearDownTestDependencies() async {
  await GetIt.instance.reset();
}
