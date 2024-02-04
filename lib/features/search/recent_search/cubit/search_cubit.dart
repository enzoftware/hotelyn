import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchLoadSuccess());

  static const searchTag = 'searchTag';
}
