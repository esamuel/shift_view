import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: const [
          // ... existing actions ...
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AIChatHistory(),
          ),
          const AIInputField(),
          // The ElevatedButton for "Add to Home Screen" has been removed from here
        ],
      ),
    );
  }
}
