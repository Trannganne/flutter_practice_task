import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/connectivity/connectivity_cubit.dart';

import 'package:flutterpractisetasks/video_player/bloc/connectivity/connectivity_state.dart';

/// Banner cố định (KHÔNG phải toast/SnackBar) báo offline — hiện liên tục
/// trong lúc mất mạng, tự ẩn khi có mạng lại. Đặt ở đầu mỗi màn hình có
/// gọi API (Home, Search).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        // Chưa biết trạng thái thật (lần check đầu chưa xong) hoặc đang
        // online -> không chiếm chỗ trên UI.
        if (!state.isKnown || state.isOnline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: Colors.amber.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              Icon(Icons.wifi_off, size: 16, color: Colors.black),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Không có kết nối mạng — đang hiển thị nội dung đã lưu.',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
