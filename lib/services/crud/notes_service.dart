import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note.dart';

class NotesService {
  Database? _db;

  DatabaseUser? _user;

  List<DatabaseNote> _notes = [];

  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await _openDatabase();
      return _db!;
    }
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // USERS TABLE
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE
        )
        ''');

        // NOTES TABLE
        await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          text TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id)
        )
        ''');
      },
    );
  }

  // ================= USER =================

  Future<DatabaseUser> getOrCreateUser({
    required String email,
  }) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      final existingUser =
          DatabaseUser.fromRow(result.first);

      _user = existingUser;
      return existingUser;
    }

    final userId = await db.insert(
      'users',
      {
        'email': email.toLowerCase(),
      },
    );

    final newUser = DatabaseUser(
      id: userId,
      email: email,
    );

    _user = newUser;
    return newUser;
  }

  // ================= NOTES =================

  Future<List<DatabaseNote>> getAllNotes() async {
    final db = await database;

    if (_user == null) {
      throw Exception("Current user not set");
    }

    final notes = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [_user!.id],
    );

    _notes =
        notes.map((note) => DatabaseNote.fromRow(note)).toList();

    _notesStreamController.add(_notes);

    return _notes;
  }

  Future<DatabaseNote> createNote() async {
    final db = await database;

    if (_user == null) {
      throw Exception("Current user not set");
    }

    const text = '';

    final id = await db.insert(
      'notes',
      {
        'user_id': _user!.id,
        'text': text,
      },
    );

    final note = DatabaseNote(
      id: id,
      userId: _user!.id,
      text: text,
    );

    _notes.add(note);

    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseNote> updateNote({
    required int id,
    required String text,
  }) async {
    final db = await database;

    await db.update(
      'notes',
      {
        'text': text,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    final updatedNote = DatabaseNote(
      id: id,
      userId: _user!.id,
      text: text,
    );

    final index = _notes.indexWhere((note) => note.id == id);

    if (index != -1) {
      _notes[index] = updatedNote;
    }

    _notesStreamController.add(_notes);

    return updatedNote;
  }

  Future<void> deleteNote(int id) async {
    final db = await database;

    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    _notes.removeWhere((note) => note.id == id);

    _notesStreamController.add(_notes);
  }

  void dispose() {
    _notesStreamController.close();
  }
}