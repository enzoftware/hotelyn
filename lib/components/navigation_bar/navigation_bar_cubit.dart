import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_state.dart';

class NavigationBarCubit extends Cubit<NavigationBarState> {
  NavigationBarCubit() : super(NavigationBarState(selectedTabIndex: 0));

  void updateSelectedIndex(int index) =>
      emit(state.copyWith(selectedTabIndex: index));
}
