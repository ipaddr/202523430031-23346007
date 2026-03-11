import 'package:flutter/material.dart';

class CreateUpdateNoteView extends StatelessWidget {
  const CreateUpdateNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: const Center(
        child: Text('Create your note here'),
      ),
    );
  }
}