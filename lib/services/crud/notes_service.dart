import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note.dart';

class NotesService {
  Database? _db;

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

  Future<List<DatabaseNote>> getAllNotes() async {
    final db = await database;

    final notes = await db.query('notes');

    _notes = notes.map((note) => DatabaseNote.fromRow(note)).toList();

    _notesStreamController.add(_notes);

    return _notes;
  }

  Future<DatabaseNote> createNote() async {
    final db = await database;

    const text = '';

    final id = await db.insert(
      'notes',
      {
        'text': text,
      },
    );

    final note = DatabaseNote(
      id: id,
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