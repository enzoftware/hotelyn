import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/profile/profile_cubit.dart';
import 'package:hotelyn/features/profile/profile_tab.dart';

void main() {
  testWidgets('pump widget', (tester) async {
    tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => ProfileCubit(),
          child: const ProfileTab(),
        ),
      ),
    );
  });
}
