import 'package:flutter/widgets.dart';
import 'package:flutterpractisetasks/image_caching/hard/services/local_storage/photolocaldb.dart';
import 'package:flutterpractisetasks/image_caching/hard/services/pexel/pexel_api.dart';
import 'package:flutterpractisetasks/image_caching/hard/services/piscum/piscum_api.dart';
import 'package:flutterpractisetasks/image_caching/models/pexel_collection.dart';
import 'package:flutterpractisetasks/image_caching/models/pexel_model.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';
import 'package:flutterpractisetasks/image_caching/models/piscum_model.dart';
import 'package:flutterpractisetasks/connectivity_check/connectivity_service.dart';

class PhotoRepository {
  // Xử lý phần gọi dữ liệu tổng hợp từ pexel và picsum
  final ConnectivityService connectivity = ConnectivityService();
  final Photolocaldb localDb = Photolocaldb();

  Future<List<PhotoEnity>> getPhotos({required int page}) async {
    if (await connectivity.hasInternet()) {
      try {
        final pexelsJson = await PexelApi.getPexelPhotos_Map(page: page);
        final picsumJson = await PiscumApi.getPiscum_Map(page: page);

        final photos = [
          ...pexelsJson.map((j) => PhotoEnity.fromPexels(j)),
          ...picsumJson.map((j) => PhotoEnity.fromPiscums(j)),
        ];

        for (final p in photos) {
          await localDb.addPhoto(photo: p, page: page);
        }
        debugPrint('Thành công rồi nè!');
        return photos;
      } catch (e) {
        debugPrint('Lỗi khi tải photos: $e');
        return localDb.getPhotos(); // fallback nếu API lỗi
      }
    } else {
      debugPrint('Không có kết nối internet');
      final maps = await localDb.getPhotos();
      debugPrint('Số lượng ảnh trong local db: ${maps.length}');
      return localDb.getPhotos();
    }
  }

  // PEXEL
  Future<List<PexelModel>> getPexelPhotos() async {
    final json = await PexelApi.getPexelPhotos_Map();

    final photos = json.map((j) => PexelModel.fromJson(j)).toList();
    return photos;
  }

  Future<List<PexelCollections>> getCollectionsApi() async {
    if (await connectivity.hasInternet()) {
      final json = await PexelApi.getPexelCollection_Map();

      final collections = json
          .map((j) => PexelCollections.fromJson(j))
          .toList();

      final updateCollections = await Future.wait(
        collections.map((c) async {
          try {
            final photoList = await PhotoRepository().getPhotosByCollectionId(
              c.id,
              perpage: 1,
              page: 1,
            );

            if (photoList.isNotEmpty) {
              final coverUrl =
                  photoList.first.url; // Lấy ảnh đầu tiên làm coverUrl
              debugPrint('Cập nhật coverUrl cho collection ${c.id}: $coverUrl');
              return c.copyWith(coverUrl: coverUrl);
            }
          } catch (e) {
            debugPrint('Lỗi khi tải coverUrl: $e');
          }
          return c;
        }),
      );
      for (final c in collections) {
        await localDb.addCollection(collection: c);
      }

      return updateCollections;
    } else {
      final updateCollections = await localDb.getCollections();
      debugPrint(
        'Số lượng collections trong local db: ${updateCollections.length}',
      );

      return updateCollections;
    }
  }

  Future<List<PhotoEnity>> getPhotosByCollectionId(
    String id, {
    int page = 1,
    int perpage = 1,
  }) async {
    final json = await PexelApi.getPexelPhotos_ByCollectionId(
      id,
      perPage: perpage,
      page: page,
    );

    final photos = <PhotoEnity>[];
    for (final j in json) {
      if (j['type'] != 'Photo' || j['src'] == null) {
        debugPrint('Bỏ qua media không hợp lệ: ${j['id']}: ${j['type']}');
        continue;
      }

      try {
        final photo = PhotoEnity.fromPexels(j);
        photos.add(photo);
        await Photolocaldb().addPhoto(photo: photo, page: page);
      } catch (e) {
        debugPrint('Lỗi khi tạo PhotoEnity từ JSON: $e');
      }
    }

    debugPrint(
      'Số ảnh trong collection ở tầng repository $id: ${photos.length}',
    );
    for (final photo in photos) {}
    return photos;
  }

  //=================================== MOCK DATA ===================================
  // Future<List<PexelCollections>> getCollections_MockData() async {
  //   final photos = await getPexel();

  //   await Future.delayed(const Duration(milliseconds: 500));

  //   return [
  //     PexelCollections(id: "c1", title: "Nature", photoCount: 4),
  //     PexelCollections(id: "c2", title: "Lifestyle", photoCount: 3),
  //     PexelCollections(id: "c3", title: "Animals & Cars", photoCount: 3),
  //   ];
  // }
  //=================================== MOCK DATA ===================================
  // PICsUM

  Future<List<PiscumModel>> getPhotoPiscumFromApi() async {
    final json = await PiscumApi.getPiscum_Map();
    final piscumPhotos = json.map((j) => PiscumModel.fromJson(j)).toList();
    return piscumPhotos;
  }
}
