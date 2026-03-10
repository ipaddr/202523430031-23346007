import 'package:flutter/material.dart';
import '../constants/routes.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Enter your email',
            ),
          ),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your password',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(notesRoute);
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
    );
  }
}