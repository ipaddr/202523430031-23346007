import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _email,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),

            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                try {

                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _email.text,
                    password: _password.text,
                  );

                  Navigator.of(context).pushNamed(notesRoute);

                } on FirebaseAuthException catch (e) {

                  if (e.code == 'user-not-found') {
                    showErrorDialog(context, 'User not found');
                  } else if (e.code == 'wrong-password') {
                    showErrorDialog(context, 'Wrong password');
                  } else {
                    showErrorDialog(context, 'Authentication error');
                  }

                }
              },

              child: const Text('Login'),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(registerRoute);
              },
              child: const Text('Not registered yet? Register here!'),
            )

          ],
        ),
      ),
    );
  }
}

Future<void> showErrorDialog(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          )
        ],
      );
    },
  );
}