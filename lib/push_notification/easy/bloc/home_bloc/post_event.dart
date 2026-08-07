import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

// Load lần đầu
class PostStarted extends PostEvent {}

class FetchPostEvent extends PostEvent {}
