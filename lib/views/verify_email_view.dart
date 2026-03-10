import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import '../constants/routes.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                'We have sent a verification email to your address.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              const Text(
                'Please check your email and click the verification link.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  await AuthService().sendEmailVerification();
                },
                child: const Text('Resend Verification Email'),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {

                  final user = AuthService().currentUser;

                  await user?.reload();

                  final refreshedUser = AuthService().currentUser;

                  if (refreshedUser != null && refreshedUser.emailVerified) {

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );

                  }

                },
                child: const Text('I Have Verified'),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () async {

                  await AuthService().logout();

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );

                },
                child: const Text('Restart'),
              )

            ],
          ),
        ),
      ),
    );
  }
}