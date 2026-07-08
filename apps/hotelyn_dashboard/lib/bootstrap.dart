import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/widgets.dart';
import 'package:hotelyn_dashboard/core/config/app_config.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Fail fast in release mode if the API endpoint was not injected.
  // Run with --dart-define-from-file=.dart_defines/<env>.json for every
  // non-local build.
  assert(
    !kReleaseMode || !AppConfig.apiBaseUrl.startsWith('http://127.0.0.1'),
    'API_BASE_URL must be set via --dart-define-from-file for release builds. '
    'Current value is the localhost fallback.',
  );

  if (!kReleaseMode) {
    log('API endpoint: ${AppConfig.apiBaseUrl}');
  }

  runApp(await builder());
}
