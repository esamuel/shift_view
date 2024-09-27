import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
          // The ElevatedButton for "Add to Home Screen" has been removed
          const AIInputField(),
        ],
      ),
    );
  }
}
