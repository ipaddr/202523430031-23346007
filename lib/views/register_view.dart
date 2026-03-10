import 'package:flutter/material.dart';
import '../constants/routes.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

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

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
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