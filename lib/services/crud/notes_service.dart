import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotesService {

  static Database? _db;

  Future<Database> get database async {

    if (_db != null) {
      return _db!;
    }

    _db = await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          text TEXT
        )
        ''');

      },
    );
  }

  Future<int> createNote(String text) async {

    final db = await database;

    return await db.insert(
      'notes',
      {'text': text},
    );

  }

  Future<List<Map<String, dynamic>>> getNotes() async {

    final db = await database;

    return await db.query('notes');

  }

  Future<int> updateNote(int id, String text) async {

    final db = await database;

    return await db.update(
      'notes',
      {'text': text},
      where: 'id = ?',
      whereArgs: [id],
    );

  }

  Future<int> deleteNote(int id) async {

    final db = await database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

  }
}