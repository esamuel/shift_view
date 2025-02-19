import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/ShiftManagerApp.png', // Updated to use your logo
              height: 100,
            ),
            const SizedBox(height: 20),
            // Brief Introduction
            Text(
              'Welcome to Shift View!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Easily track your work hours and earnings with our app.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Google Sign-In Button
            ElevatedButton.icon(
              onPressed: () async {
                // Implement Google Sign-In logic here
                final GoogleSignIn googleSignIn = GoogleSignIn();
                try {
                  final GoogleSignInAccount? account = await googleSignIn.signIn();
                  if (account != null) {
                    // Handle successful sign-in
                  }
                } catch (error) {
                  // Handle sign-in error
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 