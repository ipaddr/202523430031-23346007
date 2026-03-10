import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void showErrorDialog(BuildContext context, String text) {
    showDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [

          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),

          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {

                final userCredential =
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                final user = userCredential.user;

                if (user != null) {

                  if (user.emailVerified) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                    );
                  }

                }

              } on FirebaseAuthException catch (e) {

                if (e.code == 'user-not-found') {
                  showErrorDialog(context, 'User not found');
                } else if (e.code == 'wrong-password') {
                  showErrorDialog(context, 'Wrong password');
                } else if (e.code == 'invalid-email') {
                  showErrorDialog(context, 'Invalid email');
                } else {
                  showErrorDialog(context, 'Authentication error');
                }

              }
            },
            child: const Text('Login'),
          ),

          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Not registered yet? Register here!'),
          ),
        ],
      ),
    );
  }
}