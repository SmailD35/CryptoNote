import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto_note/model/note.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CryptoDatabase {
  static final CryptoDatabase instance = CryptoDatabase._init();

  static Database? _database;

  CryptoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('crypto_note.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit();

    var dbFactory = databaseFactoryFfi;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    final dbPath = join(appDocPath, filePath);

    var db = await dbFactory.openDatabase(dbPath);
    await _createDB(db);

    return db;
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  Future _createDB(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tableName ( 
      ${NoteFields.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
      ${NoteFields.address} TEXT NOT NULL,
      ${NoteFields.comment} TEXT NOT NULL,
      ${NoteFields.owner} TEXT NOT NULL,
      ${NoteFields.time} TEXT NOT NULL
      )
    ''');
  }

  Future<Note> create(Note note) async {
    final db = await instance.database;

    final id = await db.insert(tableName, note.toJSON());
    return note.copy(id: id);
  }

  Future<Note> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableName,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJSON(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    const orderBy = '${NoteFields.time} ASC';

    final result = await db.query(tableName, orderBy: orderBy);

    return result.map((json) => Note.fromJSON(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableName,
      note.toJSON(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableName,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }
}
