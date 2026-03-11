import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/login_view.dart';
import 'views/verify_email_view.dart';
import 'constants/routes.dart';
import 'views/register_view.dart';
import 'views/notes_view.dart';
import 'views/create_update_note_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fajar Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        verifyEmailRoute: (context) => const VerifyEmailView(),
        registerRoute: (context) => const RegisterView(),
        loginRoute: (context) => const LoginView(),
        notesRoute: (context) => const NotesView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
      home: const LoginView(),
    );
  }
}