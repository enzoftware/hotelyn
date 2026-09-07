import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_state.dart';

import 'package:hotelyn/core/services/clarity_service.dart';

class NavigationBarCubit extends Cubit<NavigationBarState> {
  NavigationBarCubit({
    required this.clarityService,
  }) : super(const NavigationBarState(selectedTabIndex: 0)) {
    clarityService.setCurrentScreenName(_screenNames[0]);
  }

  final ClarityService clarityService;

  static const _screenNames = ['home', 'search', 'messages', 'profile'];

  void updateSelectedIndex(int index) {
    clarityService.setCurrentScreenName(_screenNames[index]);
    emit(state.copyWith(selectedTabIndex: index));
  }
}
