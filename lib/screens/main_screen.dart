import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'info_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
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
