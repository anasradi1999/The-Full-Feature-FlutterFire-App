import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logic/notifications_cubit.dart';
import 'logic/notifications_state.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit()..fetchNotifications(),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError) {
            return Center(child: Text(state.message));
          }

          if (state is NotificationsLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return const Center(child: Text('لا توجد إشعارات حالياً'));
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final doc = notifications[index];
                final notification = doc.data() as Map<String, dynamic>;
                final isRead = notification['isRead'] ?? false;

                return Dismissible(
                  key: Key(doc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    context
                        .read<NotificationCubit>()
                        .deleteNotification(doc.id);
                  },
                  child: ListTile(
                    title: Text(notification['title'] ?? ''),
                    subtitle: Text(notification['body'] ?? ''),
                    trailing: isRead
                        ? null
                        : const Icon(Icons.circle,
                        color: Colors.red, size: 12),
                    onTap: () {
                      context
                          .read<NotificationCubit>()
                          .markAsRead(doc.id);
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}