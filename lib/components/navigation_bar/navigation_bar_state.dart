class NavigationBarState {
  NavigationBarState({
    required this.selectedTabIndex,
  });

  final int selectedTabIndex;

  NavigationBarState copyWith({int? selectedTabIndex}) {
    return NavigationBarState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}
