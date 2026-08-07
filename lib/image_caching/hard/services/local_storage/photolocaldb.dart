import 'package:flutter/cupertino.dart';
import 'package:flutterpractisetasks/image_caching/hard/services/local_storage/databasehelper.dart';
import 'package:flutterpractisetasks/image_caching/models/pexel_collection.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';
import 'package:sqflite/sqflite.dart';

class Photolocaldb {
  Future<Database> get _db async => Databasehelper.instance.database;

  // Private Helper
  Map<String, dynamic> _toMap(PhotoEnity photo, {required int page}) {
    return {
      'id': photo.id,
      'url': photo.url,
      'photographer': photo.photoGrapher,
      'description': photo.description,
      'source': photo.source.name,
      'height': photo.height,
      'width': photo.width,
      'cachedAt': DateTime.now().toIso8601String(),
      'page': page,
    };
  }

  PhotoEnity _fromMap(Map<String, dynamic> map) {
    return PhotoEnity(
      id: map['id'] as String,
      url: map['url'] as String,
      photoGrapher: map['photographer'] as String,
      description: map['description'] as String?,
      source: PhotoType.values.byName(map['source'] as String),
      height: map['height'] as int,
      width: map['width'] as int,
    );
  }

  Map<String, dynamic> _toMapFavorite(String id) {
    return {'photo_id': id, 'favoritedAt': DateTime.now().toIso8601String()};
  }

  Future<List<PhotoEnity>> getFavoritePhotos() async {
    final db = await _db;

    final maps = await db.rawQuery('''
                        SELECT p.* from photos p
                        INNER JOIN favorites f on f.photo_id=p.id
                      ''');
    return maps.map((m) => _fromMap(m).copyWith(isFavorited: true)).toList();
  }

  Future<bool> addPhoto({required PhotoEnity photo, required int page}) async {
    await Future.delayed(Duration(microseconds: 200));

    final db = await _db;

    try {
      await db.insert(
        'photos',
        _toMap(photo, page: page),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      debugPrint('Thêm ảnh thất bại!: $e');
      return false;
    }
  }

  Future<bool> addFavorite({required PhotoEnity photo}) async {
    await Future.delayed(Duration(microseconds: 200));

    final db = await _db;

    try {
      await db.insert(
        'favorites',
        _toMapFavorite(photo.id),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Thêm favorite thành công!');
      return true;
    } catch (e) {
      debugPrint('Thêm favorite thất bại: $e');
      return false;
    }
  }

  //  Thêm phần collections
  // Xử lý chuyển đổi PexelCollections thành Map<String, dynamic>
  Map<String, dynamic> _toMapCollection(PexelCollections collection) {
    return {
      'id': collection.id,
      'title': collection.title,
      'description': collection.description,
      'coverUrl': collection.coverUrl,
      'totalPhotos': collection.photoCount,
      'cachedAt': DateTime.now().toIso8601String(),
    };
  }

  // Lấy danh sách collections( khi mất mạng)
  Future<List<PexelCollections>> getCollections() async {
    await Future.delayed(Duration(seconds: 1));
    final db = await _db;

    final maps = await db.query(
      'collections',
      orderBy: 'cachedAt DESC',
    ); // Sắp xếp giảm dần theo cachedAt
    return maps.map((m) => PexelCollections.fromJson(m)).toList();
  }

  Future<bool> addCollection({required PexelCollections collection}) async {
    await Future.delayed(Duration(microseconds: 200));

    final db = await _db;

    try {
      await db.insert(
        'collections',
        _toMapCollection(collection),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Thêm collections thành công!');
      return true;
    } catch (e) {
      debugPrint('Thêm collections thất bại: $e');
      return false;
    }
  }

  // Phần làm việc với data không thực hiện đổi giá trị
  // Flow Favorites: user toggle(hàm) => kiểm tra isFavorited( hàm)
  // => Nếu true( đã thích): remove favorite
  // Ngược lại: add favorite

  // Hàm kiểm tra
  Future<bool> isFavorited({required String id}) async {
    final db = await _db;
    final result = await db.query(
      'favorites',
      where: 'photo_id=?',
      whereArgs: [id],
    );

    return result.isNotEmpty;
  }

  // Toggle
  Future<bool> toggleFavorite({required PhotoEnity photo}) async {
    final result = await isFavorited(id: photo.id);

    // Kiểm tra xem ảnh đã được thích chưa
    // Nếu đã thích thì xóa khỏi danh sách yêu thích, ngược lại thì thêm vào
    return result
        ? await removeFavorite(id: photo.id)
        : await addFavorite(photo: photo);
  }

  // Dành cho sự kiện xóa yêu thích
  Future<bool> removeFavorite({required String id}) async {
    final db = await _db;
    try {
      await db.delete('favorites', where: 'photo_id=?', whereArgs: [id]);
      return true;
    } catch (e) {
      debugPrint('Xóa thất bại! Vui lòng thử lại!');
      return false;
    }
  }

  Future<List<PhotoEnity>> getPhotos() async {
    await Future.delayed(Duration(seconds: 1));
    final db = await _db;

    final maps = await db.query(
      'photos',
      orderBy: 'page ASC',
    ); // Sắp xếp tăng dần theo page
    return maps.map(_fromMap).toList();
  }
}
