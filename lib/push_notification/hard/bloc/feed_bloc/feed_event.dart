import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeedEvent extends FeedEvent {
  final int page;
  FetchFeedEvent({this.page = 1});
}

class LoadMoreFeedEvent extends FeedEvent {}

class RefreshFeedEvent extends FeedEvent {}
