import 'package:flutter/material.dart';
import '../services/crud/notes_service.dart';
import '../services/crud/note.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() =>
      _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState
    extends State<CreateUpdateNoteView> {

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _notesService = NotesService();
    _textController = TextEditingController();
  }

  Future<void> _createOrGetExistingNote(BuildContext context) async {

    final widgetNote =
        ModalRoute.of(context)?.settings.arguments
            as DatabaseNote?;

    // jika note lama → gunakan note lama
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return;
    }

    // jika note baru → buat note baru
    final existingNote = _note;
    if (existingNote != null) return;

    final newNote = await _notesService.createNote();
    _note = newNote;
  }

  @override
  void dispose() {
    final note = _note;
    final text = _textController.text;

    if (note != null) {
      if (text.isEmpty) {
        _notesService.deleteNote(note.id);
      } else {
        _notesService.updateNote(
          id: note.id,
          text: text,
        );
      }
    }

    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _createOrGetExistingNote(context),

      builder: (context, snapshot) {

        switch (snapshot.connectionState) {

          case ConnectionState.done:

            return Scaffold(
              appBar: AppBar(
                title: const Text('Your Note'),
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

          default:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}