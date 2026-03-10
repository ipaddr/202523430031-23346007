import 'package:flutter/material.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'We have sent you an email verification. Please check your email to verify your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            const Text(
              'If you did not receive the email, press the button below.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // nanti digunakan untuk kirim ulang email verifikasi
              },
              child: const Text('Send email verification again'),
            ),

            TextButton(
              onPressed: () {
                // nanti digunakan untuk logout / restart
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}