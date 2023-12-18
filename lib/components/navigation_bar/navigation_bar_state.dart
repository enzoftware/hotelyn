class NavigationBarState {
  final int selectedTabIndex;

  NavigationBarState({
    required this.selectedTabIndex,
  });

  NavigationBarState copyWith({int? selectedTabIndex}) {
    return NavigationBarState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}
