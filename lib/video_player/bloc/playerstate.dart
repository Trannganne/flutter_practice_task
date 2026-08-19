import 'package:equatable/equatable.dart';

enum LoadStatus { initial, loading, success, failed }

class Playerstate extends Equatable {
  final LoadStatus loadStatus;
  final String? actionMessage;

  const Playerstate({this.loadStatus = LoadStatus.initial, this.actionMessage});

  @override
  List<Object?> get props => [loadStatus, actionMessage];
}
