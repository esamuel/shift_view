import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print('HomeScreen initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('About to show upcoming shifts dialog');
      _showUpcomingShiftsDialog();
    });
  }

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

  void _showUpcomingShiftsDialog() {
    print('_showUpcomingShiftsDialog called');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upcoming Shifts'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Shift A: 9:00 AM - 5:00 PM'),
              Text('2. Shift B: 2:00 PM - 10:00 PM'),
              Text('3. Shift C: 10:00 PM - 6:00 AM'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
