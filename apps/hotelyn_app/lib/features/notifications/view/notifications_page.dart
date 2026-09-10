import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/notifications/cubit/notifications_cubit.dart';
import 'package:hotelyn/features/notifications/widgets/notification_tile.dart';

/// Notifications page displaying real-time booking updates, promotions, and
/// system alerts.
///
/// Complies strictly with Figma frame `115:2615` ("05 - Notification").
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    this.cubit,
    super.key,
  });

  static const route = '/notifications';

  final NotificationsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: const _NotificationsView(),
      );
    }

    return BlocProvider(
      create: (_) => NotificationsCubit(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaliforniaColors.surfacePrimary,
      appBar: CaliforniaTopBar.general(
        title: 'Notification',
        backButtonLabel: 'Back',
        onBack: () => Navigator.of(context).pop(),
        menuButtonLabel: 'More Options',
        onMenuTap: () {
          // Additional notification options
        },
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.notifications.isEmpty) {
            return const _EmptyNotifications();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: CaliforniaSpacing.xl,
            ),
            children: [
              const SizedBox(height: CaliforniaSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Recent',
                        style: CaliforniaTypography.h4,
                      ),
                      if (state.unreadCount > 0) ...[
                        const SizedBox(width: CaliforniaSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: CaliforniaColors.brandPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.unreadCount}',
                            style: CaliforniaTypography.p12Medium.copyWith(
                              color: CaliforniaColors.surfaceElevated,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (state.unreadCount > 0)
                    GestureDetector(
                      onTap: () {
                        context.read<NotificationsCubit>().markAllAsRead();
                      },
                      child: Text(
                        'Mark All Read',
                        style: CaliforniaTypography.p14Medium.copyWith(
                          color: CaliforniaColors.brandPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: CaliforniaSpacing.sm),
              for (var i = 0; i < state.notifications.length; i++) ...[
                if (i > 0)
                  const Divider(
                    color: CaliforniaColors.divider,
                    height: 1,
                  ),
                NotificationTile(
                  item: state.notifications[i],
                  onTap: () {
                    context.read<NotificationsCubit>().markAsRead(
                      state.notifications[i].id,
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CaliforniaSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.bell_slash,
              size: 64,
              color: CaliforniaColors.disabled,
            ),
            const SizedBox(height: CaliforniaSpacing.lg),
            const Text(
              'No Notifications',
              style: CaliforniaTypography.h3,
            ),
            const SizedBox(height: CaliforniaSpacing.xs),
            Text(
              'You have no unread notifications at the moment.',
              style: CaliforniaTypography.p14Regular.copyWith(
                color: CaliforniaColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
