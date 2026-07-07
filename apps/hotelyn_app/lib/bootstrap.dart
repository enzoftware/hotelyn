import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hotelyn/core/config/app_config.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Fail fast in release mode if the GraphQL endpoint was not injected.
  // Run with --dart-define-from-file=.dart_defines/<env>.json for every
  // non-local build.
  assert(
    !kReleaseMode || !AppConfig.graphqlUrl.startsWith('http://127.0.0.1'),
    'GRAPHQL_URL must be set via --dart-define-from-file for release builds. '
    'Current value is the localhost fallback.',
  );

  if (!kReleaseMode) {
    log('GraphQL endpoint: ${AppConfig.graphqlUrl}');
  }

  final config = ClarityConfig(
    projectId: 'vaoffuzfn7',
    logLevel: kReleaseMode ? LogLevel.None : LogLevel.Verbose,
  );

  runApp(
    ClarityWidget(
      app: await builder(),
      clarityConfig: config,
    ),
  );
}
