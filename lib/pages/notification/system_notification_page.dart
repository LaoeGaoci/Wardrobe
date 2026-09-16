import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/notification/push_notification_payload.dart';

class SystemNotificationPage extends StatelessWidget {
  final PushNotificationPayload payload;

  const SystemNotificationPage({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final title = payload.title ?? l10n.notificationSystemTitle;

    final body = payload.body ?? l10n.notificationSystemBody;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemNotificationTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 24),

            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            Text(
              body,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
