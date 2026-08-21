class TimeFormatter {
  /// Nhận timestamp (milliseconds), tự tính khoảng cách rồi format
  String formatTimeAgoFromTimestamp(int timestampMillis) {
    final secondsAgo =
        (DateTime.now().millisecondsSinceEpoch - timestampMillis) ~/ 1000;
    return formatTimeAgo(secondsAgo);
  }

  String formatTimeAgo(int seconds) {
    if (seconds < 60) return 'just now';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m ago';
    final hours = minutes ~/ 60;
    if (hours < 24) return '${hours}h ago';
    final days = hours ~/ 24;
    if (days < 7) return '${days}d ago';
    final weeks = days ~/ 7;
    if (weeks < 4) return '${weeks}w ago';
    final months = days ~/ 30;
    if (months < 12) return '${months}mo ago';
    final years = days ~/ 365;
    return '${years}y ago';
  }

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);

    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Duration parseDuration(String duration) {
    final parts = duration.split(':');

    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);

    return Duration(minutes: minutes, seconds: seconds);
  }
}
