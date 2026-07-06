import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/messages/messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit() : super(MessagesEmpty()) {
    _load();
  }

  void _load() {}
}
