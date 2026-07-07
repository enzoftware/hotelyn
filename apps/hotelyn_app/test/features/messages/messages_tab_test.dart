import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/messages/messages_cubit.dart';
import 'package:hotelyn/features/messages/messages_state.dart';
import 'package:hotelyn/features/messages/messages_tab.dart';
import 'package:mocktail/mocktail.dart';

class MockMessagesCubit extends Mock implements MessagesCubit {}

void main() {
  group('MessagesTab::', () {
    late MessagesCubit cubit;

    setUp(() {
      cubit = MockMessagesCubit();
    });

    Future<void> buildWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            home: MessagesTab(),
          ),
        ),
      );
    }

    testWidgets('Messages tab when state is MessagesEmpty', (tester) async {
      final state = MessagesEmpty();
      whenListen<MessagesState>(
        cubit,
        Stream.fromIterable([]),
        initialState: state,
      );
      await buildWidget(tester);
      final screenType = find.byType(MessagesEmptyScreen);
      expect(cubit.state, isA<MessagesEmpty>());
      expect(screenType, findsOneWidget);
    });

    testWidgets('Messages tab when state is MessagesLoading', (tester) async {
      final state = MessagesLoading();
      whenListen<MessagesState>(
        cubit,
        Stream.fromIterable([]),
        initialState: state,
      );
      await buildWidget(tester);
      final screenType = find.byType(MessagesLoadingScreen);
      expect(cubit.state, isA<MessagesLoading>());
      expect(screenType, findsOneWidget);
    });

    testWidgets('Messages tab when state is MessagesError', (tester) async {
      final state = MessagesError();
      whenListen<MessagesState>(
        cubit,
        Stream.fromIterable([]),
        initialState: state,
      );
      await buildWidget(tester);
      final screenType = find.byType(MessagesErrorScreen);
      expect(cubit.state, isA<MessagesError>());
      expect(screenType, findsOneWidget);
    });

    testWidgets('Messages tab when state is MessagesLoadSuccess',
        (tester) async {
      final state = MessagesLoadSuccess();
      whenListen<MessagesState>(
        cubit,
        Stream.fromIterable([]),
        initialState: state,
      );
      await buildWidget(tester);
      final screenType = find.byType(MessagesLoadSuccessScreen);
      expect(cubit.state, isA<MessagesLoadSuccess>());
      expect(screenType, findsOneWidget);
    });
  });
}
