import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/search/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());
}
