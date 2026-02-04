import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required ClarityService clarityService,
  })  : _clarityService = clarityService,
        super(SearchLoadSuccess()) {
    _clarityService.setCurrentScreenName('search');
  }

  final ClarityService _clarityService;

  static const searchTag = 'searchTag';
}
