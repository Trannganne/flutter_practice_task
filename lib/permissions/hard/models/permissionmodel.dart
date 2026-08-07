class Permissionmodel {
  final String name;
  final bool isGranted;

  Permissionmodel({required this.name, required this.isGranted});

  Map<String, dynamic> toJson() {
    return {'name': name, 'isGranted': isGranted};
  }

  factory Permissionmodel.fromJson(Map<String, dynamic> json) {
    return Permissionmodel(name: json['name'], isGranted: json['isGranted']);
  }
}
