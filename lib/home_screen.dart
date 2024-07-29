import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

// ... rest of the HomeScreen class ...

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Text('Welcome, ${appState.userName}!'),
      ),
    );
  }
}