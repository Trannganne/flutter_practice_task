import 'package:flutter/cupertino.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/file_picker/services/localstorage/databasehelper.dart';
import 'package:sqflite/sqflite.dart';

class UploadLocaldb {
  Future<Database> get _db async => UploadLocalDatabase.instance.database;

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
        .map((m) => UploadModel.fromJson(m).copyWith(status: UploadStatus.Done))
        .toList();
  }

  // Xóa task
  Future<bool> deleteUploadTask({required String id}) async {
    final db = await _db;
    try {
      await db.delete('upload_tasks', where: 'id=?', whereArgs: [id]);
      return true;
    } catch (e) {
      debugPrint('Xóa task thất bại!: $e');
      return false;
    }
  }

  Future<bool> addUploadTask({required UploadModel item}) async {
    await Future.delayed(Duration(microseconds: 200));

    final db = await _db;

    try {
      await db.insert(
        'upload_tasks',
        item.toJson(),
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
        {
          'status': status.name,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id=?',
        whereArgs: [id],
      );
      debugPrint(
        'Cập nhật trạng thái upload thành công: hiện tại là ${status.name}',
      );
      return true;
    } catch (e) {
      debugPrint('Cập nhật trạng thái upload thất bại: $e');
      return false;
    }
  }

  // Cập nhật thông tin 1 task

  //Cập nhập trạng thái upload
  Future<bool> updateTask({
    required String id,
    required UploadModel item,
  }) async {
    await Future.delayed(Duration(microseconds: 200));

    final db = await _db;
    try {
      await db.update(
        'upload_tasks',
        item.toJson(),

        where: 'id=?',
        whereArgs: [id],
      );
      debugPrint(
        'Cập nhật upload model thành công: hiện tại là ${item.status.name}',
      );
      return true;
    } catch (e) {
      debugPrint('Cập nhật upload model thất bại: $e');
      return false;
    }
  }

  // Lấy danh sách task đang upload(uploading) hoặc treo( pending)
  Future<List<UploadModel>> getUploadingOrPending() async {
    final db = await _db;
    try {
      final json = await db.query(
        'upload_tasks',
        where: 'status IN(?,?)',
        whereArgs: [UploadStatus.pending.name, UploadStatus.uploading.name],
        orderBy: 'createdAt ASC',
      );
      final tasks = json.map((j) => UploadModel.fromJson(j)).toList();
      return tasks;
    } catch (e) {
      debugPrint('Lấy danh sách thất bại: $e');
      return [];
    }
  }

  // Tìm hash ( kiểm tra trùng)
  Future<UploadModel?> findByHash(String hash) async {
    final db = await _db;

    try {
      final rows = await db.query(
        'upload_tasks',
        where: 'fileHash =?',
        whereArgs: [hash],
      );
      if (rows.isEmpty) return null;
      return UploadModel.fromJson(rows.first);
    } catch (e) {
      debugPrint("Lỗi khi lấy dữ liệu hash: $e");
      return null;
    }
  }

  // Lấy danh sách tasks (file) đã hoàn tất upload
  Future<List<UploadModel>?> getCompletedTasks({
    required int limit,
    required int offset,
  }) async {
    final db = await _db;

    try {
      final rows = await db.query(
        'upload_tasks',
        where: 'status=?',
        whereArgs: [UploadStatus.Done.name],
        orderBy: 'updatedAt DESC',
        limit: limit,
        offset: offset,
      );
      if (rows.isEmpty) return null;
      return rows.map((row) => UploadModel.fromJson(row)).toList();
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách file đã upload: $e');
      return null;
    }
  }

  // Lấy task theo id

  Future<UploadModel?> getTaskById(String id) async {
    final db = await _db;
    try {
      final row = await db.query(
        'upload_tasks',
        where: 'id=?',
        whereArgs: [id],
      );
      if (row.isEmpty) return null;
      return UploadModel.fromJson(row.first);
    } catch (e) {
      debugPrint('Lỗi khi lấy task theo id: $e');
      return null;
    }
  }
}
