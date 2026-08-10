import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UploadLocalDatabase {
  // Singleton - toàn app chỉ dùng 1 instance duy nhất
  static final UploadLocalDatabase instance = UploadLocalDatabase._internal();

  UploadLocalDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    // Nếu đã khởi tạo rồi thì trả về luôn, không tạo lại
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Tìm đường dẫn lưu file .db trên thiết bị
    final dbPath = await getDatabasesPath();
    debugPrint(dbPath);

    final path = join(dbPath, 'upload_task.db');
    return await openDatabase(path, version: 1, onCreate: _createUploadTable);
  }

  Future<void> _createUploadTable(Database db, int version) async {
    await db.execute('''
          CREATE TABLE upload_tasks(
          id TEXT PRIMARY KEY,
          filePath TEXT NOT NULL,
          fileHash TEXT NOT NULL, 
          provider TEXT,
          status TEXT NOT NULL,
          remoteUrl TEXT NOT NULL,
          retryCount INTEGER DEFAULT 0,
          createdAt INTEGER NOT NULL ,
          updatedAt INTEGER NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE history(
          task_id TEXT PRIMARY KEY,
          uploadedAt INTEGER NOT NULL,
          FOREIGN KEY (task_id) REFERENCES upload_tasks(id) ON DELETE CASCADE)
''');
  }
}
