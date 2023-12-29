import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/messages/messages_cubit.dart';
import 'package:hotelyn/features/messages/messages_state.dart';

void main() {
  group('MessagesCubit', () {
    test('constructor', () {
      final cubit = MessagesCubit();
      expect(cubit.state, isA<MessagesEmpty>());
    });
  });
}
