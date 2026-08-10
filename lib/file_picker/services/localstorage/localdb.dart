import 'package:flutter/cupertino.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/image_caching/hard/services/local_storage/databasehelper.dart';
import 'package:sqflite/sqflite.dart';

class Photolocaldb {
  Future<Database> get _db async => Databasehelper.instance.database;

  // Private Helper
  Map<String, dynamic> _toMap(UploadModel item) {
    return {
      'id': item.id,
      'filePath': item.filePath,
      'fileHash': item.fileHash,
      'provider': item.provider,
      'status': item.status,
      'remoteUrl': item.remoteUrl,
      'retryCount': item.retryCount,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': item.updatedAt,
    };
  }

  UploadModel _fromMap(Map<String, dynamic> map) {
    return UploadModel(
      id: map['id'] as String,
      filePath: map['filePath'] as String,
      fileHash: map['fileHash'] as String,
      provider: ProviderType.values.byName(map['provider'] as String),
      status: UploadStatus.values.byName(map['source'] as String),
      createdAt: map['height'] as int,
      updatedAt: map['width'] as int,
      retryCount: map['retryCountr'] as int,
      remoteUrl: map['remoteUrl'] as String,
    );
  }

  Map<String, dynamic> _toMapHistory(String id) {
    return {'task_id': id, 'uploadedAt': DateTime.now().toIso8601String()};
  }

  Future<List<UploadModel>> getHistory() async {
    final db = await _db;

    final maps = await db.rawQuery('''
                        SELECT p.* from upload_tasks t
                        INNER JOIN history h on h.task_id=t.id
                      ''');
    return maps
        .map((m) => _fromMap(m).copyWith(status: UploadStatus.success))
        .toList();
  }

  Future<bool> addUploadTask({required UploadModel item}) async {
    await Future.delayed(Duration(microseconds: 200));

    final db = await _db;

    try {
      await db.insert(
        'upload_tasks',
        _toMap(item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      debugPrint('Thêm task thất bại!: $e');
      return false;
    }
  }

  Future<bool> addHistory({required UploadModel item}) async {
    await Future.delayed(Duration(microseconds: 200));

    final db = await _db;

    try {
      await db.insert(
        'history',
        _toMapHistory(item.id),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Thêm lịch sử thành công!');
      return true;
    } catch (e) {
      debugPrint('Thêm lịch sử upload thất bại: $e');
      return false;
    }
  }

  //Cập nhập trạng thái upload
  Future<bool> updateStatus({
    required String id,
    required UploadStatus status,
  }) async {
    await Future.delayed(Duration(microseconds: 200));

    final db = await _db;
    try {
      await db.update(
        'upload_tasks',
        {'status': status, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
        where: 'id=?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('Cập nhật trạng thái upload thất bại!');
      return false;
    }
  }

  // Lấy danh sách task đang upload(uploading) hoặc treo( pending)
  Future<List<UploadModel>?> getUploadingOrPending() async {
    await Future.delayed(Duration(milliseconds: 10));

    final db = await _db;
    try {
      final json = await db.query(
        'upload_tasks',
        where: 'status in(?,?)',
        whereArgs: [UploadStatus.pending, UploadStatus.uploading],
      );
      final tasks = json.map((j) => UploadModel.fromJson(j)).toList();
      return tasks;
    } catch (e) {
      debugPrint('Lấy danh sách thất bại!');
      return null;
    }
  }
}
