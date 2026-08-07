import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/image_caching/models/pexel_collection.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';

class _Unset {
  const _Unset();
}

const _unSet = _Unset();

enum PhotoStatus { initial, loading, success, failure }

class PhotoState extends Equatable {
  final PhotoStatus status;
  final List<PexelCollections> collections;
  final List<PhotoEnity> photos;

  final int columnCount;
  final int currentPage;
  final int totalPages;
  final String? actionMessage;
  final List<PhotoEnity> pagePhotos;

  // Quản lý phần phân trang( load more )
  final bool hasMore;
  final bool isLoadingMore;

  // Quản lý phần yêu thích
  final List<PhotoEnity> favoritePhotos;

  // Quản lý phần load dữ liệu cho collection( photos theo collectionId ) cụ thể
  final List<PhotoEnity> collectionPhotos;
  final bool hasMoreCollectionPhotos;
  final bool isLoadingMoreCollectionPhotos;
  final int currentCollectionPage;
  final int currentCollectionId;

  // Quản lý trạng thái cho retry per page
  final bool loadMoreFailed;

  const PhotoState({
    this.status = PhotoStatus.initial,
    this.collections = const [],
    this.photos = const [], //
    this.columnCount = 3,
    this.currentPage = 1,
    this.actionMessage,
    this.totalPages = 1,
    this.pagePhotos = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.favoritePhotos = const [],

    // Phần quản lý load dữ liệu theo collectionId
    this.collectionPhotos = const [],
    this.hasMoreCollectionPhotos = true,
    this.isLoadingMoreCollectionPhotos = false,
    this.currentCollectionPage = 1,
    this.currentCollectionId = 0,
    this.loadMoreFailed = false,
  });

  PhotoState copyWith({
    PhotoStatus? status,
    List<PexelCollections>? collections,
    int? columnCount,
    int? currentPage,
    Object? actionMessage = _unSet,
    int? totalPages,
    List<PhotoEnity>? pagePhotos,

    List<PhotoEnity>? photos,

    List<PhotoEnity>? favoritePhotos,
    bool? hasMore,
    bool? isLoadingMore,

    // Phần quản lý load dữ liệu theo collectionId
    List<PhotoEnity>? collectionPhotos,
    bool? hasMoreCollectionPhotos,
    bool? isLoadingMoreCollectionPhotos,
    int? currentCollectionPage,
    int? currentCollectionId,

    bool? loadMoreFailed,
  }) {
    return PhotoState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      photos: photos ?? this.photos,
      columnCount: columnCount ?? this.columnCount,
      currentPage: currentPage ?? this.currentPage,
      actionMessage: identical(actionMessage, _unSet)
          ? this.actionMessage
          : actionMessage as String?,
      totalPages: totalPages ?? this.totalPages,
      pagePhotos: pagePhotos ?? this.pagePhotos,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      favoritePhotos: favoritePhotos ?? this.favoritePhotos,

      // Phần quản lý load dữ liệu theo collectionId
      collectionPhotos: collectionPhotos ?? this.collectionPhotos,
      hasMoreCollectionPhotos:
          hasMoreCollectionPhotos ?? this.hasMoreCollectionPhotos,
      isLoadingMoreCollectionPhotos:
          isLoadingMoreCollectionPhotos ?? this.isLoadingMoreCollectionPhotos,
      currentCollectionPage:
          currentCollectionPage ?? this.currentCollectionPage,
      currentCollectionId: currentCollectionId ?? this.currentCollectionId,

      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    collections,
    photos,
    columnCount,
    currentPage,
    actionMessage,
    totalPages,
    pagePhotos,
    hasMore,
    isLoadingMore,
    favoritePhotos,

    // Phần quản lý load dữ liệu theo collectionId
    collectionPhotos,
    hasMoreCollectionPhotos,
    isLoadingMoreCollectionPhotos,
    currentCollectionPage,
    currentCollectionId,

    loadMoreFailed,
  ];
}
