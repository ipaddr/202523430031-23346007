import 'package:flutter/material.dart';
import '../services/crud/notes_service.dart';
import '../services/crud/note.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _textController = TextEditingController();
    _createNote();
  }

  Future<void> _createNote() async {
    final note = await _notesService.createNote();
    _note = note;
  }

  Future<void> _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _notesService.deleteNote(note.id);
    }
  }

  Future<void> _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        id: note.id,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),

      body: TextField(
        controller: _textController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Start typing your note...',
        ),

        onChanged: (text) async {
          final note = _note;

          if (note != null) {
            await _notesService.updateNote(
              id: note.id,
              text: text,
            );
          }
        },
      ),
    );
  }
}