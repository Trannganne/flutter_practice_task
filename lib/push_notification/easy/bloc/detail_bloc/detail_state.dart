import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/push_notification/easy/models/post.dart';

sealed class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostDetailLoadSuccess extends PostDetailState {
  final Post post;
  final String? actionMessage;

  PostDetailLoadSuccess({required this.post, required this.actionMessage});
}

class PostDetailLoadFailure extends PostDetailState {
  final String message;

  PostDetailLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
