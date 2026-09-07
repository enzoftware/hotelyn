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

  static const homeIndex = 0;
  static const searchIndex = 1;
  static const messagesIndex = 2;
  static const profileIndex = 3;

  static const _screenNames = ['home', 'search', 'messages', 'profile'];

  void updateSelectedIndex(int index) {
    if (index >= 0 && index < _screenNames.length) {
      clarityService.setCurrentScreenName(_screenNames[index]);
      emit(state.copyWith(selectedTabIndex: index));
    }
  }

  void switchToHome() => updateSelectedIndex(homeIndex);
  void switchToSearch() => updateSelectedIndex(searchIndex);
  void switchToMessages() => updateSelectedIndex(messagesIndex);
  void switchToProfile() => updateSelectedIndex(profileIndex);
}
