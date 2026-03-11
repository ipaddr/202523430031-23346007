import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import '../constants/routes.dart';
import '../services/crud/notes_service.dart';
import '../services/crud/note.dart';

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
    _notesService.getAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          )
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
                    );
                  },
                );

              } else {
                return const Center(
                  child: Text('No notes available'),
                );
              }

            default:
              return const Center(
                child: Text('Something went wrong'),
              );
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}