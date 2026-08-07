import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/settingbloc/setting_bloc.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/settingbloc/setting_event.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/settingbloc/setting_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  IconData _getIcon(String category) {
    return switch (category) {
      'technology' => Icons.computer_outlined,
      'business' => Icons.business_center_outlined,
      'general' => Icons.newspaper_outlined,
      'sports' => Icons.sports_soccer_outlined,
      'health' => Icons.health_and_safety_outlined,
      'science' => Icons.science_outlined,
      'entertainment' => Icons.movie_outlined,
      _ => Icons.article_outlined,
    };
  }

  String _getLabel(String category) {
    return switch (category) {
      'technology' => 'Technology',
      'business' => 'Business',
      'general' => 'General',
      'sports' => 'Sports',
      'health' => 'Health',
      'science' => 'Science',
      'entertainment' => 'Entertainment',
      _ => category,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingBloc()..add(FetchSubscriptionsEvent()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            title: Commontext(
              title: 'Cài đặt thông báo',
              fontWeight: FontWeight.bold,
              fontSize: "18",
              colorText: Colors.white,
            ),
          ),
          body: BlocConsumer<SettingBloc, SettingState>(
            builder: (context, state) {
              return switch (state) {
                SettingInitial() => const SizedBox.shrink(),

                SettingLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),

                SettingLoadFailure(:final message) => Center(
                  child: Text(message),
                ),

                SettingLoadSuccess() => _buildList(
                  context,
                  state as SettingLoadSuccess,
                ),
              };
            },
            listener: (context, state) {
              if (state is SettingLoadSuccess && state.actionMessage != null) {
                Apptoast.show(state.actionMessage!);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, SettingLoadSuccess state) {
    return ListView(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Chọn category bạn muốn nhận thông báo khi có tin mới',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Danh sách category
        ...state.subscriptions.keys.map((category) {
          final isOn = state.subscriptions[category]!;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isOn ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIcon(category),
                    color: isOn ? Colors.blueAccent : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                title: Text(
                  _getLabel(category),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  isOn ? 'Đang nhận thông báo' : 'Tắt thông báo',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOn ? Colors.blueAccent : Colors.grey.shade400,
                  ),
                ),
                trailing: Switch(
                  value: isOn,
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    // Gửi event thay vì setState
                    context.read<SettingBloc>().add(
                      ToggleSubscriptionEvent(category: category, value: value),
                    );

                    // Hiện snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Đã bật thông báo: ${_getLabel(category)}'
                              : 'Đã tắt thông báo: ${_getLabel(category)}',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, indent: 70),
            ],
          );
        }),
      ],
    );
  }
}
