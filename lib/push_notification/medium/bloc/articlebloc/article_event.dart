import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object?> get props => [];
}

class ArticleStarted extends ArticleEvent {}

class FetchArticleEvent extends ArticleEvent {
  final String category;

  const FetchArticleEvent({this.category = 'general'});
}

class OnIncomingNotificationEvent extends ArticleEvent {
  final RemoteMessage message;

  const OnIncomingNotificationEvent({required this.message});
}
