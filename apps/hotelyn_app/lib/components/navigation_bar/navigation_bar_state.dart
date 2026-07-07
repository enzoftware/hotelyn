import 'package:equatable/equatable.dart';

class NavigationBarState extends Equatable {
  const NavigationBarState({
    required this.selectedTabIndex,
  });

  final int selectedTabIndex;

  NavigationBarState copyWith({int? selectedTabIndex}) {
    return NavigationBarState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object> get props => [selectedTabIndex];
}
