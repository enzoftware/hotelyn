import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:hotelyn/features/notifications/models/notification_item.dart';

/// Notification list tile matching Figma node `136:2866`.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.item,
    this.onTap,
    super.key,
  });

  final NotificationItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconData = switch (item.type) {
      NotificationType.message => CupertinoIcons.chat_bubble_text_fill,
      NotificationType.systemAlert => CupertinoIcons.bell_fill,
      NotificationType.promotion => CupertinoIcons.tag_fill,
      NotificationType.bookingUpdate => CupertinoIcons.checkmark_seal_fill,
    };

    final iconColor = switch (item.type) {
      NotificationType.message => CaliforniaColors.brandPrimary,
      NotificationType.systemAlert => CaliforniaColors.warning,
      NotificationType.promotion => CaliforniaColors.success,
      NotificationType.bookingUpdate => CaliforniaColors.brandSecondary,
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: CaliforniaSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                if (!item.isRead)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: CaliforniaColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: CaliforniaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: CaliforniaTypography.p14Medium.copyWith(
                            fontWeight: item.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: CaliforniaSpacing.xs),
                      Text(
                        item.timeAgo,
                        style: CaliforniaTypography.p12Regular.copyWith(
                          color: CaliforniaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CaliforniaSpacing.xs),
                  Text(
                    item.description,
                    style: CaliforniaTypography.p12Regular.copyWith(
                      color: CaliforniaColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
