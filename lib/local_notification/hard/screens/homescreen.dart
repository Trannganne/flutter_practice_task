import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_bloc.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_event.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_state.dart';
import 'package:flutterpractisetasks/local_notification/hard/models/notificationhistory.dart';
import 'package:flutterpractisetasks/local_notification/hard/services/planner_history_cacheservice.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/apptoast.dart';
import 'package:go_router/go_router.dart';
// Import các widget con tái sử dụng
import 'widgets/reminder_card.dart';
import 'widgets/notification_history_card.dart';

class HardDashboardScreen extends StatefulWidget {
  //final PlannerUimodel uiModel;

  const HardDashboardScreen({super.key});

  @override
  State<HardDashboardScreen> createState() => _HardDashboardScreenState();
}

class _HardDashboardScreenState extends State<HardDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // final currentForecast = widget.uiModel.forecast.current;

    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(), // Quay lại Menu chính
        ),
        title: const Text(
          'Reminder Center',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<PlannerBloc, PlannerState>(
        listener: (context, state) {
          if (state is PlannerLoadSuccess && state.actionMessage != null) {
            Apptoast.show(state.actionMessage!);
          }
        },
        builder: (context, state) {
          return switch (state) {
            PlannerInitial() => const SizedBox.shrink(),

            PlannerNeedLocationPermission() => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Đang xin quyền...'),
                ],
              ),
            ),

            PlannerLoading() => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Đang tải planner...'),
                ],
              ),
            ),

            PlannerLoadFailure(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<PlannerBloc>().add(RetryPlannerEvent()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),

            PlannerLoadSuccess() => _buildLoaded(
              context,
              state as PlannerLoadSuccess,
            ),
          };
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PlannerLoadSuccess state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER INFO ---
          _buildHeader(
            state.planner.forecast.current.temp.round(),
            state.planner.forecast.cityName,
            state.planner.forecast.current.icon!,
          ),
          const SizedBox(height: 24),
          Text(
            'Upcoming Reminders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),

          // --- REMINDERS SECTION ---
          ReminderCard(
            title: 'Daily Activity',
            subtitle: state.planner.activity.activity,
            timeInfo: 'Tomorrow, 8:00 AM',
            iconData: Icons.wb_sunny_outlined,
            iconColor: Colors.orange,
            isEnabled: state.planner.activityEnabled,
            onChanged: (val) {
              context.read<PlannerBloc>().add(
                ToggleActivityReminderEvent(isEnabled: val),
              );
            },
          ),
          const SizedBox(height: 12),
          ReminderCard(
            title: 'Umbrella Reminder',
            subtitle: state.planner.notificationText.isNotEmpty
                ? state.planner.notificationText
                : 'Rain expected (${(state.planner.rainProbability * 100).round()}%)',
            timeInfo: 'Today, 8:00 AM',
            iconData: Icons.umbrella_outlined,
            iconColor: Colors.purpleAccent,
            isEnabled: state.planner.forecastEnabled,
            onChanged: (val) {
              context.read<PlannerBloc>().add(
                ToggleUmbrellaReminderEvent(isEnabled: val),
              );
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Notification History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          // --- HISTORY SECTION ---
          FutureBuilder<List<NotificationHistory>>(
            future: PlannerHistoryCacheservice.getPlannerHistory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final histories = snapshot.data!;

              if (histories.isEmpty) {
                return const Text(
                  "No history",
                  style: TextStyle(color: Colors.grey),
                );
              }

              return Column(
                children: histories
                    .take(3) // chỉ lấy 3 lịch sử gần nhất
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NotificationHistoryCard(history: e),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int temp, String city, String icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Alex!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Stay on track with smart reminders.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2331),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/$icon@2x.png',
                height: 30,
                width: 30,
              ),
              // const Icon(Icons.cloud_queue, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '$temp°C\n$city',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
