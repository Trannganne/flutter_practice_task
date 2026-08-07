import 'package:equatable/equatable.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchDetailPostEvent extends PostDetailEvent {
  final int postId;

  FetchDetailPostEvent({required this.postId});
}
