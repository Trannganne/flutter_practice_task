import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databasehelper {
  // Singleton - toàn app chỉ dùng 1 instance duy nhất
  static final Databasehelper instance = Databasehelper._internal();

  Databasehelper._internal();

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
    print(dbPath);

    final path = join(dbPath, 'photo_manager.db');
    return await openDatabase(path, version: 1, onCreate: _createPhotosTable);
  }

  Future<void> _createPhotosTable(Database db, int version) async {
    await db.execute('''
          CREATE TABLE photos(
          id TEXT PRIMARY KEY,
          url TEXT NOT NULL,
          photographer TEXT NOT NULL, 
          description TEXT,
          source TEXT NOT NULL,
          page INTEGER NOT NULL,
          height INTEGER NOT NULL,
          width INTEGER NOT NULL ,
          cachedAt INTEGER NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE favorites(
          photo_id TEXT PRIMARY KEY,
          favoritedAt INTEGER NOT NULL,
          FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE)
''');

    await db.execute('''
          CREATE TABLE search_history(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           query TEXT NOT NULL,
          searchedAt INTEGER NOT NULL)
''');

    await db.execute('''
            CREATE TABLE collections(
                      id TEXT PRIMARY KEY,
                      title TEXT NOT NULL,
                      description TEXT,
                      coverUrl TEXT,
                      totalPhotos INTEGER NOT NULL,
                      cachedAt INTEGER NOT NULL)''');
  }
}
