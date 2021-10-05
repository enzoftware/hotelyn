// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'package:hotel_booking_app/app/app.dart';
import 'package:hotel_booking_app/app/app_bloc_observer.dart';
import 'package:hotel_booking_app/dependencies.dart';
import 'package:hotel_booking_app/widgets/error_widget.dart';

void main() {
  Bloc.observer = AppBlocObserver();

  ErrorWidget.builder =
      (FlutterErrorDetails details) => const CustomErrorWidget();
  setupDependencies();
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  runZonedGuarded(
    () => runApp(const HotelBookingApp()),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
