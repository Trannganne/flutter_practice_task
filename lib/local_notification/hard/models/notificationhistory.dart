class NotificationHistory {
  final String title;
  final String body;
  final DateTime time;
  final String type;
  // Note: Khi cần sự xác nhận thì nhớ thêm vào phần model để có thể update lại
  final String status;

  NotificationHistory({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.status = 'sent',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'time': time.toIso8601String(),
    'type': type,
    'status': status,
  };

  factory NotificationHistory.fromJson(Map<String, dynamic> json) {
    return NotificationHistory(
      title: json['title'],
      body: json['body'],
      time: DateTime.parse(json['time']),
      type: json['type'],
      status: json['status'] ?? 'sent',
    );
  }
}
