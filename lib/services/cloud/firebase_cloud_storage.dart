import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloud_note.dart';
import 'firebase_cloud_constants.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  // create note
  Future<CloudNote> createNewNote({
    required String ownerUserId,
  }) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });

    final fetchedNote = await document.get();

    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  // update note
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    await notes.doc(documentId).update({
      textFieldName: text,
    });
  }

  // delete note
  Future<void> deleteNote({
    required String documentId,
  }) async {
    await notes.doc(documentId).delete();
  }

  // get all notes for one user
  Stream<Iterable<CloudNote>> allNotes({
    required String ownerUserId,
  }) {
    return notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map(
              (doc) => CloudNote.fromSnapshot(
                doc.data(),
                doc.id,
              ),
            ));
  }
}