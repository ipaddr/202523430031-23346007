import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import '../constants/routes.dart';
import '../services/crud/notes_service.dart';
import '../services/crud/note.dart';
import 'notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final NotesService _notesService = NotesService();

  @override
  void initState() {
    super.initState();
    _setupUser();
  }

  // ambil user firebase lalu load notes miliknya
  Future<void> _setupUser() async {
    final user = AuthService().currentUser;

    if (user != null) {
      await _notesService.getOrCreateUser(
        email: user.email!,
      );

      await _notesService.getAllNotes();
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      loginRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () async {
              await _logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: StreamBuilder<List<DatabaseNote>>(
        stream: _notesService.allNotes,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case ConnectionState.active:
              if (snapshot.hasData) {
                final notes = snapshot.data!;

                if (notes.isEmpty) {
                  return const Center(
                    child: Text('No Notes Yet'),
                  );
                }

                return NotesListView(
                  notes: notes,

                  // delete note
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(
                      note.id,
                    );
                  },

                  // edit existing note
                  onTap: (note) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              }

              return const Center(
                child: Text('No notes available'),
              );

            default:
              return const Center(
                child: Text('Something went wrong'),
              );
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            createOrUpdateNoteRoute,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}