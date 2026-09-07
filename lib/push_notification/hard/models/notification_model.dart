class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String sourceName;
  final DateTime receivedAt;
  final bool isRead;
  final String? url;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.sourceName,
    required this.receivedAt,
    this.isRead = false,
    this.url,
  });

  // copyWith cần thiết vì object immutable
  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      sourceName: sourceName,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
      url: url,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'sourceName': sourceName,
    'receivedAt': receivedAt.toIso8601String(),
    'isRead': isRead,
    'url': url,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      sourceName: json['sourceName'],
      receivedAt: DateTime.parse(json['receivedAt']),
      isRead: json['isRead'] ?? false,
      url: json['url'] ?? '',
    );
  }
}
