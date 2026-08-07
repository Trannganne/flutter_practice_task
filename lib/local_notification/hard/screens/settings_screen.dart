import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_bloc.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_event.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_state.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';

class HardSettingsScreen extends StatelessWidget {
  const HardSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'System Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocConsumer<PlannerBloc, PlannerState>(
        listener: (context, state) {
          if (state is PlannerLoadSuccess && state.actionMessage != null) {
            Apptoast.show(state.actionMessage!);
          }
        },
        builder: (context, state) {
          if (state is PlannerLoadSuccess) {
            final planner = state.planner;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Nhóm cấu hình chạy ngầm
                _buildSettingsGroup(
                  title: 'BACKGROUND SERVICES',
                  children: [
                    _buildSettingRow(
                      icon: Icons.sync_rounded,
                      iconColor: Colors.blueAccent,
                      title: 'Background Worker Sync',
                      subtitle: 'Cho phép cập nhật dữ liệu ngầm định kỳ.',
                      trailing: Switch(
                        value: planner.syncEnabled, // Lấy cờ từ Bloc dữ liệu
                        onChanged: (v) {
                          // Bạn có thể kích hoạt event ToggleBackgroundSyncEvent ở đây nếu cần mở comment code Bloc
                          context.read<PlannerBloc>().add(
                            ToggleBackgroundSyncEvent(isEnabled: v),
                          );
                        },
                        activeColor: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nhóm cấu hình ngưỡng logic
                _buildSettingsGroup(
                  title: 'NOTIFICATION PREFERENCES',
                  children: [
                    _buildSettingRow(
                      icon: Icons.umbrella_rounded,
                      iconColor: Colors.purpleAccent,
                      title: 'Rain Threshold Probability',
                      subtitle: 'Ngưỡng kích hoạt thông báo nhắc mang ô.',
                      trailing: SizedBox(
                        width: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(planner.rainThreshold * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                              ),
                              child: Slider(
                                value: planner.rainThreshold * 100,
                                min: 0,
                                max: 100,
                                divisions: 20, // 0,5,10,...100
                                label:
                                    '${(planner.rainThreshold * 100).round()}%',
                                onChanged: (value) {
                                  context.read<PlannerBloc>().add(
                                    UpdateRainThresholdEvent(value / 100),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildSettingRow(
                      icon: Icons.dark_mode_outlined,
                      iconColor: Colors.indigoAccent,
                      title: 'Quiet Hours (DND)',
                      subtitle: 'Tự động tắt tiếng thông báo từ 10 PM - 7 AM.',
                      trailing: Switch(
                        value: true,
                        onChanged: (v) {},
                        activeColor: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              'Đang tải thông số cấu hình...',
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161C26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF222B3C)),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return children[index];
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F141C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
