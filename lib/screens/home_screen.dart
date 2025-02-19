import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/shift.dart';
import 'package:intl/intl.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${appState.userName}!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showUpcomingShiftsDialog,
              child: const Text('View Upcoming Shifts'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpcomingShiftsDialog() {
    print('_showUpcomingShiftsDialog called');
    final appState = Provider.of<AppState>(context, listen: false);

    // Get shifts and sort them in reverse chronological order
    List<Shift> upcomingShifts = List<Shift>.from(appState.shifts)
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort in descending order

    // Take only the first 10 shifts (most recent)
    upcomingShifts = upcomingShifts.take(10).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upcoming Shifts'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: upcomingShifts.map((shift) {
                final dateStr = DateFormat('MMM dd, yyyy').format(shift.date);
                final startTime = shift.startTime != null
                    ? DateFormat('HH:mm').format(shift.startTime!)
                    : 'N/A';
                final endTime = shift.endTime != null
                    ? DateFormat('HH:mm').format(shift.endTime!)
                    : 'N/A';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '$dateStr: $startTime - $endTime (${shift.totalHours} hours)',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
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
