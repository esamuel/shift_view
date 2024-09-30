import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Add to Home Screen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'To add this app to your home screen, follow these steps:\n\n'
              '1. Open the app in your mobile browser\n'
              '2. Tap the browser menu (usually three dots or lines)\n'
              '3. Look for an option like "Add to Home Screen" or "Install"\n'
              '4. Confirm the action\n\n'
              'The app icon will appear on your home screen for easy access.',
            ),
          ],
        ),
      ),
    );
  }
}