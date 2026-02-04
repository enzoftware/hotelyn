import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchLoadSuccess()) {
    Clarity.setCurrentScreenName('search');
  }

  static const searchTag = 'searchTag';
}
