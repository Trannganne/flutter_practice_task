import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/medium/bloc/forecast_bloc.dart';
import 'package:flutterpractisetasks/local_notification/medium/bloc/forecast_event.dart';

class RainProbabilityCard extends StatelessWidget {
  final int percentage;
  final bool isScheduled;
  final double threshold;
  final ValueChanged<double> onThresholdChanged;

  const RainProbabilityCard({
    super.key,
    required this.percentage,
    required this.isScheduled,
    required this.threshold,
    required this.onThresholdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Phần hiển thị Phần trăm mưa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.umbrella, size: 36, color: Colors.blue),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'High chance of rain',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Bring an umbrella!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Thanh LinearProgressIndicator biểu thị phần trăm
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: Color.fromARGB(255, 21, 101, 192),
            ), // Nét đứt ẩn hoặc mờ nhẹ
          ),

          // 2. Phần thiết lập Notification Setup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.notifications_active,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Setup',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Remind me to bring an umbrella if rain is expected.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Nút Toggle Switch điều khiển trạng thái bật/tắt
              Switch(
                value: isScheduled,
                onChanged: (bool value) {
                  // Gọi Event BLoC tương ứng để bật tắt notification tại đây nếu cần
                  context.read<WeatherBloc>()
                    ..add(ToggleScheduleEvent(isEnabled: value));
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hàng Dropdown chọn ngưỡng phần trăm mưa để thông báo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notify if rain probability is above',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: threshold,
                    items: const [0.3, 0.4, 0.5, 0.6, 0.7]
                        .map(
                          (value) => DropdownMenuItem<double>(
                            value: value,
                            child: Text('${(value * 100).toInt()}%'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onThresholdChanged(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
