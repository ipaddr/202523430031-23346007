import 'package:flutter/material.dart';
import '../services/crud/note.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];

        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          onTap: () {
            onTap(note);
          },

          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDeleteNote(note);
            },
          ),
        );
      },
    );
  }
}