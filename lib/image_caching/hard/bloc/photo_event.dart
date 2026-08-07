import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';

class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object?> get props => [];
}

class LoadCollectionsEvent extends PhotoEvent {}

class LoadExploreDataEvent extends PhotoEvent {}

class LoadPhotosEvent extends PhotoEvent {}

class LoadPhotosPiscumEvent extends PhotoEvent {}

// Load photos thuộc collection cụ thể
class LoadPhotosByCollectionIdEvent extends PhotoEvent {
  final String collectionId;
  const LoadPhotosByCollectionIdEvent(this.collectionId);

  @override
  List<Object?> get props => [];
}

class ColumnCountChange extends PhotoEvent {
  final int count;

  const ColumnCountChange(this.count);
  @override
  List<Object?> get props => [count];
}

class PageChange extends PhotoEvent {
  final int page;
  final int currentPage;
  final int columnCount;

  const PageChange(this.page, this.currentPage, this.columnCount);
  @override
  List<Object?> get props => [page, currentPage, columnCount];
}

// Favorites
class ToggleFavoritesEvent extends PhotoEvent {
  final PhotoEnity photo;

  const ToggleFavoritesEvent(this.photo);

  @override
  List<Object?> get props => [photo];
}

// Load dữ liệu photoEnity
class LoadPhotoEnityEvent extends PhotoEvent {
  final int page;
  const LoadPhotoEnityEvent(this.page);
  @override
  List<Object?> get props => [page];
}

class LoadMoreEvent extends PhotoEvent {}

class RefreshEvent extends PhotoEvent {}

class LoadFavoritesEvent extends PhotoEvent {}

class LoadMoreCollectionPhotosEvent extends PhotoEvent {
  final String collectionId;
  const LoadMoreCollectionPhotosEvent(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

class RetryPageEvent extends PhotoEvent {
  final int page;
  const RetryPageEvent(this.page);

  @override
  List<Object?> get props => [page];
}
