import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/push_notification/easy/models/post.dart';

sealed class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoadSuccess extends PostState {
  final List<Post> posts;
  final String? actionMessage;

  PostLoadSuccess({required this.posts, required this.actionMessage});
}

class PostLoadFailure extends PostState {
  final String message;

  const PostLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
