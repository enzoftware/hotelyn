import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _items = [
  CaliforniaNavigationBarItem(
    icon: CupertinoIcons.house,
    activeIcon: CupertinoIcons.house_fill,
    label: 'Home',
  ),
  CaliforniaNavigationBarItem(
    icon: CupertinoIcons.search,
    activeIcon: CupertinoIcons.search,
    label: 'Search',
  ),
  CaliforniaNavigationBarItem(
    icon: CupertinoIcons.chat_bubble,
    activeIcon: CupertinoIcons.chat_bubble_fill,
    label: 'Messages',
  ),
  CaliforniaNavigationBarItem(
    icon: CupertinoIcons.person,
    activeIcon: CupertinoIcons.person_fill,
    label: 'Profile',
  ),
];

@widgetbook.UseCase(name: 'Interactive', type: CaliforniaNavigationBar)
Widget buildCaliforniaNavigationBarInteractiveUseCase(BuildContext context) {
  return _InteractiveNavigationBar(
    initialIndex: context.knobs.int.slider(
      label: 'currentIndex',
      max: _items.length - 1,
    ),
  );
}

/// Wraps [CaliforniaNavigationBar] with local state so the `Interactive`
/// use-case's tabs are actually selectable in the Widgetbook UI.
class _InteractiveNavigationBar extends StatefulWidget {
  const _InteractiveNavigationBar({required this.initialIndex});

  final int initialIndex;

  @override
  State<_InteractiveNavigationBar> createState() =>
      _InteractiveNavigationBarState();
}

class _InteractiveNavigationBarState extends State<_InteractiveNavigationBar> {
  late int _index = widget.initialIndex;

  @override
  void didUpdateWidget(_InteractiveNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CaliforniaNavigationBar(
      items: _items,
      currentIndex: _index,
      onTap: (index) => setState(() => _index = index),
    );
  }
}
