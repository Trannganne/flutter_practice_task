import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_event.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_state.dart';
import 'package:flutterpractisetasks/image_caching/hard/repository/photo_repository.dart';
import 'package:flutterpractisetasks/image_caching/hard/services/local_storage/photolocaldb.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc() : super(const PhotoState()) {
    on<LoadCollectionsEvent>(_onLoadCollections);
    on<PageChange>(_onPageChange);
    on<ColumnCountChange>(_onColumnCountChange);
    on<LoadExploreDataEvent>(_onLoadExploreData);
    on<LoadPhotosByCollectionIdEvent>(_onLoadPhotosByCollectionId);
    on<ToggleFavoritesEvent>(_onToggleFavorites);
    on<LoadPhotoEnityEvent>(_onLoadPhotoEnity);
    on<LoadMoreEvent>(_onLoadMore);
    on<RefreshEvent>(_onRefresh);
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<LoadMoreCollectionPhotosEvent>(
      _onLoadMoreCollectionPhotos,
      transformer: droppable(),
    );

    // Retry theo page( khi quá trình tải lỗi thì những trang đã tải rồi vẫn giữ nguyên,
    //chỉ render lại trang bị lỗi)
    // on<RetryPageEvent>(_onRetryPage);
  }

  // Retry page khi tải lỗi
  // Chú ý: Kiểm tra lại logic của hàm _updatePagination để đảm bảo
  // nó chỉ cập nhật đúng trang bị lỗi mà không làm ảnh hưởng đến các trang khác

  // Lưu ý: tải lại trang ở phần pagination hay phần infinite scroll
  // Future<void> _onRetryPage(
  //   RetryPageEvent event,
  //   Emitter<PhotoState> emit,
  // ) async {
  //   try {
  //     // Gọi lại để tải dữ liệu cho đúng trang bị lỗi
  //     final photos = await PhotoRepository().getPhotos(page: event.page);

  //     final updatedState = state.copyWith(photos: photos);

  //     emit(_updatePagination(currentState: updatedState));
  //   } catch (e) {
  //     debugPrint('Lỗi khi tải lại trang ${event.page}: $e');
  //     emit(
  //       state.copyWith(
  //         actionMessage: 'Tải lại trang ${event.page} không thành công!',
  //       ),
  //     );
  //   }
  // }

  Future<void> _onLoadMoreCollectionPhotos(
    LoadMoreCollectionPhotosEvent event,
    Emitter<PhotoState> emit,
  ) async {
    if (state.isLoadingMoreCollectionPhotos || !state.hasMoreCollectionPhotos)
      return;

    emit(state.copyWith(isLoadingMoreCollectionPhotos: true));

    try {
      final nextPage = state.currentCollectionPage + 1;
      final newPhotos = await PhotoRepository().getPhotosByCollectionId(
        event.collectionId,
        perpage: 20,
        page: nextPage,
      );

      final updatedCollectionPhotos = List<PhotoEnity>.from(
        state.collectionPhotos,
      )..addAll(newPhotos);
      final hasMore = newPhotos.isNotEmpty;

      emit(
        state.copyWith(
          collectionPhotos: updatedCollectionPhotos,
          currentCollectionPage: nextPage,
          hasMoreCollectionPhotos: hasMore,
          isLoadingMoreCollectionPhotos: false,
          loadMoreFailed: false,
          actionMessage: null,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi khi tải thêm photos theo collection: $e');
      emit(
        state.copyWith(
          actionMessage: 'Tải thêm photos theo collection không thành công!',
          isLoadingMoreCollectionPhotos: false,
          loadMoreFailed: true,
        ),
      );
    }
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<PhotoState> emit,
  ) async {
    try {
      final favoritePhotos = await Photolocaldb().getFavoritePhotos();
      debugPrint('Số lượng ảnh favorites: ${favoritePhotos.length}');
      debugPrint('Cụ thể: $favoritePhotos');
      emit(
        state.copyWith(
          favoritePhotos: favoritePhotos,
          actionMessage: 'Tải danh sách ảnh yêu thích thành công!',
        ),
      );
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách ảnh yêu thích: $e');
      emit(
        state.copyWith(
          actionMessage: 'Tải danh sách ảnh yêu thích không thành công!',
        ),
      );
    }
  }

  Future<void> _onRefresh(RefreshEvent event, Emitter<PhotoState> emit) async {
    try {
      final refreshedPhotos = await PhotoRepository().getPhotos(page: 1);
      emit(
        state.copyWith(
          photos: refreshedPhotos,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi khi làm mới photos: $e');
      emit(state.copyWith(actionMessage: 'Làm mới photos không thành công!'));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreEvent event,
    Emitter<PhotoState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final newPhotos = await PhotoRepository().getPhotos(page: nextPage);

      final updatedPhotos = List<PhotoEnity>.from(state.photos)
        ..addAll(newPhotos);
      final hasMore = newPhotos.isNotEmpty;

      emit(
        state.copyWith(
          photos: updatedPhotos,
          currentPage: nextPage,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi khi tải thêm photos: $e');
      emit(
        state.copyWith(
          actionMessage: 'Tải thêm photos không thành công!',
          isLoadingMore: false,
        ),
      );
    }
  }

  // Xử lý sự kiện favorites
  // Hiểu rõ cần đổi giá trị ở file nào
  Future<void> _onToggleFavorites(
    ToggleFavoritesEvent event,
    Emitter<PhotoState> emit,
  ) async {
    try {
      await Photolocaldb().toggleFavorite(photo: event.photo);

      final isFavorited = await Photolocaldb().isFavorited(id: event.photo.id);
      List<PhotoEnity> updateList(List<PhotoEnity> list) => list
          .map(
            (p) => p.id == event.photo.id
                ? p.copyWith(
                    isFavorited: isFavorited,
                  ) // tạo BẢN SAO mới của đúng item đó, đổi cờ
                : p,
          ) // các item khác giữ nguyên reference
          .toList();

      final updatedFavorites = await Photolocaldb().getFavoritePhotos();

      emit(
        state.copyWith(
          photos: updateList(state.photos),
          pagePhotos: updateList(state.pagePhotos),
          favoritePhotos: updatedFavorites,
          actionMessage: 'Đã yêu thích ảnh',
          collectionPhotos: updateList(state.collectionPhotos),
        ),
      );
    } catch (e) {
      debugPrint('Xảy ra lỗi! Vui lòng kiểm tra lại!');
      emit(state.copyWith(actionMessage: 'Lưu thất bại!'));
    }
  }

  // Xử lý sự kiện tải photos theo collectionId
  Future<void> _onLoadPhotosByCollectionId(
    LoadPhotosByCollectionIdEvent event,
    Emitter<PhotoState> emit,
  ) async {
    debugPrint('BẮT ĐẦU load collection: ${event.collectionId}');
    try {
      final photos = await PhotoRepository().getPhotosByCollectionId(
        event.collectionId,
        perpage: 20,
      );

      final markedPhotos = await Future.wait(
        photos.map((p) async {
          final isFavorited = await Photolocaldb().isFavorited(id: p.id);
          return p.copyWith(isFavorited: isFavorited);
        }),
      );
      debugPrint(
        'Số ảnh có trong collection ${event.collectionId}: ${photos.length}',
      );

      emit(state.copyWith(collectionPhotos: markedPhotos, actionMessage: null));
    } catch (e) {
      debugPrint('Lỗi khi tải photos theo Collection!: $e');
      emit(
        state.copyWith(actionMessage: 'Lỗi khi tải photos theo Collection: $e'),
      );
    }
  }

  Future<void> _onLoadExploreData(
    LoadExploreDataEvent event,
    Emitter<PhotoState> emit,
  ) async {
    // Tải collections, photos
    add(LoadCollectionsEvent());
    // add(LoadPhotosEvent());
    add(LoadPhotoEnityEvent(1)); // Tải dữ liệu photoEnity từ API
  }

  Future<void> _onLoadCollections(
    LoadCollectionsEvent event,
    Emitter<PhotoState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PhotoStatus.loading));
      final collections = await PhotoRepository().getCollectionsApi();

      emit(
        state.copyWith(collections: collections, status: PhotoStatus.success),
      );
    } catch (e) {
      debugPrint('Lỗi khi tải Collections: $e');
      emit(
        state.copyWith(
          actionMessage: 'Tải collections không thành công!',
          status: PhotoStatus.failure,
        ),
      );
    }
  }

  Future<void> _onLoadPhotoEnity(
    LoadPhotoEnityEvent event,
    Emitter<PhotoState> emit,
  ) async {
    try {
      final photos = await PhotoRepository().getPhotos(page: event.page);
      debugPrint('Có tới đây hong: ${photos.length}');

      final markedPhotos = await Future.wait(
        photos.map((p) async {
          final isFavorited = await Photolocaldb().isFavorited(id: p.id);
          return p.copyWith(isFavorited: isFavorited);
        }),
      );

      final updatedState = state.copyWith(
        photos: markedPhotos,
        status: PhotoStatus.success,
      );

      emit(_updatePagination(currentState: updatedState));
    } catch (e) {
      debugPrint('Lỗi khi tải PhotoEnity: $e');
      emit(state.copyWith(actionMessage: 'Tải PhotoEnity không thành công!'));
    }
  }

  // Future<void> _onLoadPhotos(
  //   LoadPhotosEvent event,
  //   Emitter<PhotoState> emit,
  // ) async {
  //   try {
  //     final photos = await PhotoRepository().getPhotos(page: event.page);
  //     final updateState = state.copyWith(photos: photos);

  //     emit(_updatePagination(currentState: updateState));
  //   } catch (e) {
  //     debugPrint("Lỗi khi tải photos: $e");
  //     emit(
  //       state.copyWith(actionMessage: 'Tải danh sách photos không thành công!'),
  //     );
  //   }
  // }

  // Future<void> _onLoadPhotos_Piscum(
  //   LoadPhotosPiscumEvent event,
  //   Emitter<PhotoState> emit,
  // ) async {
  //   try {
  //     final photos = await PhotoRepository().getPhotoPiscumFromApi();
  //     final updateState = state.copyWith(piscum_photos: photos);
  //     debugPrint('Có tới đây hong: ${updateState.piscum_photos}');
  //     emit(_updatePagination(currentState: updateState));
  //     debugPrint('Cái này là page photos nè: ${updateState.pagePhotos}');
  //   } catch (e) {
  //     debugPrint("Lỗi khi tải piscum photos: $e");
  //     emit(
  //       state.copyWith(
  //         actionMessage: 'Tải danh sách piscum photos không thành công!',
  //       ),
  //     );
  //   }
  // }

  // Làm sao biết được data ở trong của ai
  // Hàm Helper đặt trong PhotoBloc
  PhotoState _updatePagination({
    required PhotoState currentState,
    int? page,
    int? columnCount,
  }) {
    final targetPage = page ?? currentState.currentPage;
    final targetColumns = columnCount ?? currentState.columnCount;

    // 1. Số ảnh trên 1 trang = số cột * 2 hàng
    final itemsPerPage = targetColumns * 2;

    // 2. Tính tổng số trang
    final totalPages = (currentState.photos.length / itemsPerPage).ceil().clamp(
      1,
      9999,
    );

    // 3. Cắt danh sách ảnh cho trang chỉ định
    final startIndex = (targetPage - 1) * itemsPerPage;

    List<PhotoEnity> pagePhotos = [];

    if (startIndex < currentState.photos.length) {
      final endIndex = (startIndex + itemsPerPage > currentState.photos.length)
          ? currentState.photos.length
          : startIndex + itemsPerPage;
      pagePhotos = currentState.photos.sublist(startIndex, endIndex);
    }
    debugPrint('Cái này là page photos nè: ${pagePhotos.length}');

    return currentState.copyWith(
      currentPage: targetPage,
      columnCount: targetColumns,
      totalPages: totalPages,
      pagePhotos: pagePhotos, // Đảm bảo pagePhotos chỉ có 6 ảnh!
    );
  }

  // Không hiểu chỗ này nữa nè nha
  // Cho phần bấm previous/ next page
  Future<void> _onPageChange(PageChange event, Emitter<PhotoState> emit) async {
    try {
      emit(
        _updatePagination(
          currentState: state,
          page: event.page,
          columnCount: event.columnCount,
        ),
      );
    } catch (e) {
      emit(state.copyWith(actionMessage: 'Lỗi khi tải trang: $e'));
    }
  }

  Future<void> _onColumnCountChange(
    ColumnCountChange event,
    Emitter<PhotoState> emit,
  ) async {
    emit(
      _updatePagination(columnCount: event.count, page: 1, currentState: state),
    );
  }
}
