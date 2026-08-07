class Activitymodel {
  final String key;
  final String activity;
  final String type;

  Activitymodel({
    required this.key,
    required this.activity,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {'key': key, 'activity': activity, 'type': type};
  }

  factory Activitymodel.fromJson(Map<String, dynamic> json) {
    return Activitymodel(
      key: json['key'] ?? '',
      activity: json['activity'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
