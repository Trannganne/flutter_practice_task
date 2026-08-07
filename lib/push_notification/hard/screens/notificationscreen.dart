import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/commonText.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/notificationbloc/notification_bloc.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/notificationbloc/notification_event.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/notificationbloc/notification_state.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/core/appcolor.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/layout/main_layout.dart';
import 'package:flutterpractisetasks/push_notification/medium/services/urlservice.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc()..add(LoadNotificationsEvent()),
      child: Builder(
        builder: (context) {
          return MainLayout(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Appcolor.primary,
              foregroundColor: Appcolor.textTertiary,
              title: const Text('Notification Center'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                      ClearAllNotificationsEvent(),
                    );
                  },
                  child: Commontext(
                    title: 'Clear all',
                    fontSize: '14',
                    colorText: Colors.white,
                  ),
                ),
              ],
            ),
            body: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                return switch (state) {
                  NotificationInitial() => const SizedBox.shrink(),

                  NotificationLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),

                  NotificationEmpty() => const Center(
                    child: Text('Chưa có thông báo nào'),
                  ),

                  NotificationLoadFailure(:final message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Commontext(
                          title: message,
                          fontSize: '14',
                          colorText: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.read<NotificationBloc>().add(
                              LoadNotificationsEvent(),
                            );
                          },
                          child: Commontext(title: 'Thử lại'),
                        ),
                      ],
                    ),
                  ),

                  NotificationLoadSuccess(:final notifications) =>
                    ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item = notifications[index];

                        return ListTile(
                          tileColor: item.isRead ? null : Colors.blue.shade50,
                          leading: Icon(
                            item.url != null
                                ? Icons.newspaper
                                : Icons.forum_outlined,
                            color: item.isRead
                                ? Colors.grey
                                : Colors.blueAccent,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: item.isRead
                                  ? Colors.white
                                  : const Color.fromARGB(255, 46, 119, 188),
                            ),
                          ),
                          subtitle: Text(
                            '${item.sourceName} · ${item.receivedAt}',
                            style: TextStyle(
                              color: item.isRead
                                  ? Colors.grey.shade500
                                  : const Color.fromARGB(255, 46, 119, 188),
                            ),
                          ),
                          onTap: () {
                            context.read<NotificationBloc>().add(
                              MarkAsReadEvent(id: item.id),
                            );

                            if (item.url != null) {
                              Urlservice.openArticle(item.url!);
                            }
                          },
                        );
                      },
                    ),
                };
              },
            ),
          );
        },
      ),
    );
  }
}
