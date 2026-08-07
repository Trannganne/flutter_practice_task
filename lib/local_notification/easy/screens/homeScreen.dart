import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/activity_bloc.dart';
import '../bloc/activity_event.dart';
import '../bloc/activity_state.dart';
import 'components/activity_card.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityBloc()..add(FetchActivityEvent()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.green.shade50,
          appBar: AppBar(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            title: const Text(
              'Activity Reminder',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: BlocConsumer<ActivityBloc, ActivityState>(
            listener: (context, state) {
              // Hiện snackbar khi có actionMessage
              if (state is ActivityLoadSuccess && state.actionMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.actionMessage!),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            builder: (context, state) {
              return switch (state) {
                ActivityInitial() => const SizedBox.shrink(),

                ActivityLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),

                ActivityLoadFailure(:final message, :final cachedActivity) =>
                  cachedActivity != null
                      ? _buildContent(
                          context,
                          ActivityLoadSuccess(
                            activity: cachedActivity,
                            isOffline: true,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                message,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => context
                                    .read<ActivityBloc>()
                                    .add(FetchActivityEvent()),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),

                ActivityLoadSuccess() => _buildContent(
                  context,
                  state as ActivityLoadSuccess,
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ActivityLoadSuccess state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner offline
            if (state.isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(color: Colors.orange.shade700, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 14,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Offline — đang hiện activity đã lưu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),

            // Activity card
            ActivityCard(activity: state.activity),

            const SizedBox(height: 24),

            // Nút Get Another Activity
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.read<ActivityBloc>().add(FetchActivityEvent()),
                icon: const Icon(Icons.refresh),
                label: const Text('Get Another Activity'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.green.shade600),
                  foregroundColor: Colors.green.shade600,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Toggle lịch 8:00 AM
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Reminder',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Get a notification every day',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.isScheduled,
                  activeColor: Colors.green.shade600,
                  onChanged: (value) => context.read<ActivityBloc>().add(
                    ToggleScheduleEvent(isEnabled: value),
                  ),
                ),
              ],
            ),

            // Hiện giờ lên lịch nếu đang bật
            if (state.isScheduled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('Reminder Time'),
                trailing: const Text(
                  '08:00 AM',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

            const SizedBox(height: 16),

            // Nút Test now
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.read<ActivityBloc>().add(TestNotificationEvent()),
                icon: const Icon(Icons.notifications_active),
                label: const Text('Test Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
