import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import '../constants/routes.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
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
      body: const Center(
        child: Text('Hello World'),
      ),
    );
  }
}