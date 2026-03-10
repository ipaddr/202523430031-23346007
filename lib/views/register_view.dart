import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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

                  final userCredential =
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _email.text,
                    password: _password.text,
                  );

                  await userCredential.user?.sendEmailVerification();

                  Navigator.of(context).pushNamed(verifyEmailRoute);

                } on FirebaseAuthException catch (e) {

                  if (e.code == 'weak-password') {
                    showErrorDialog(context, 'Weak password');
                  } else if (e.code == 'email-already-in-use') {
                    showErrorDialog(context, 'Email already in use');
                  } else if (e.code == 'invalid-email') {
                    showErrorDialog(context, 'Invalid email');
                  } else {
                    showErrorDialog(context, 'Registration error');
                  }

                }

              },

              child: const Text('Register'),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(loginRoute);
              },
              child: const Text('Already registered? Login here!'),
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