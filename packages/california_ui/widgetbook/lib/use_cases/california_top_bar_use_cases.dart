import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'General', type: CaliforniaTopBar)
Widget buildCaliforniaTopBarGeneralUseCase(BuildContext context) {
  return CaliforniaTopBar.general(
    title: context.knobs.string(label: 'title', initialValue: 'Page Title'),
    backButtonLabel: 'Back',
    menuButtonLabel: 'More options',
    onBack: context.knobs.boolean(label: 'with onBack', initialValue: true)
        ? () {}
        : null,
    onMenuTap:
        context.knobs.boolean(label: 'with onMenuTap', initialValue: true)
            ? () {}
            : null,
  );
}

@widgetbook.UseCase(name: 'Main screen', type: CaliforniaTopBar)
Widget buildCaliforniaTopBarMainScreenUseCase(BuildContext context) {
  return CaliforniaTopBar.mainScreen(
    title: context.knobs.string(label: 'title', initialValue: 'Search'),
    notificationsButtonLabel: 'Notifications',
    hasUnreadNotifications: context.knobs.boolean(
      label: 'hasUnreadNotifications',
      initialValue: true,
    ),
    onNotificationsTap: () {},
  );
}

@widgetbook.UseCase(name: 'Search by map', type: CaliforniaTopBar)
Widget buildCaliforniaTopBarSearchByMapUseCase(BuildContext context) {
  return CaliforniaTopBar.searchByMap(
    title: context.knobs.string(
      label: 'title',
      initialValue: 'Purwokerto',
    ),
    backButtonLabel: 'Back',
    searchButtonLabel: 'Search',
    onBack: () {},
    onSearchTap: () {},
  );
}

@widgetbook.UseCase(name: 'Detail product', type: CaliforniaTopBar)
Widget buildCaliforniaTopBarDetailProductUseCase(BuildContext context) {
  return ColoredBox(
    color: CaliforniaColors.textPrimary,
    child: CaliforniaTopBar.detailProduct(
      backButtonLabel: 'Back',
      onBack: () {},
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CaliforniaTopBarCircleButton(
            icon: CupertinoIcons.share,
            scrim: true,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          CaliforniaTopBarCircleButton(
            icon: CupertinoIcons.heart,
            scrim: true,
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Message', type: CaliforniaTopBar)
Widget buildCaliforniaTopBarMessageUseCase(BuildContext context) {
  return CaliforniaTopBar.message(
    backButtonLabel: 'Back',
    menuButtonLabel: 'More options',
    onBack: () {},
    onMenuTap: () {},
    leading: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(radius: 22, child: Icon(CupertinoIcons.person)),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.knobs.string(
                label: 'name',
                initialValue: 'Kim Hayo',
              ),
            ),
            const Text('Online'),
          ],
        ),
      ],
    ),
  );
}
