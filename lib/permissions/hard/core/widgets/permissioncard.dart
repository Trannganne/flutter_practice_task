import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_state.dart';

class PermissionCard extends StatelessWidget {
  final String label;
  final PermissionState status;
  final IconData icon;

  const PermissionCard({
    super.key,
    required this.label,
    required this.status,
    required this.icon,
  });

  Color get _getStatusColor {
    switch (status) {
      case PermissionState.granted:
        return const Color(0xFF10B981);
      case PermissionState.denied:
        return Colors.orangeAccent;
      case PermissionState.permanentlyDenied:
        return Colors.redAccent;
      case PermissionState.initial:
        return Colors.grey;
    }
  }

  String get _getLabel {
    switch (status) {
      case PermissionState.granted:
        return 'Granted';
      case PermissionState.denied:
        return 'Denied';
      case PermissionState.permanentlyDenied:
        return 'Blocked';
      case PermissionState.initial:
        return 'Not asked';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getLabel,
                style: TextStyle(
                  color: _getStatusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
