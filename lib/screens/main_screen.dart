import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'info_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const InfoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Shifts'),
      ),
      body: Column(
        children: [
          _buildUpcomingShiftsCard(),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildUpcomingShiftsCard() {
    // TODO: Replace with actual shift data
    final shifts = [
      {'day': 'Mon', 'date': '2023-04-10', 'start': '09:00', 'end': '17:00', 'total': '8h'},
      {'day': 'Wed', 'date': '2023-04-12', 'start': '10:00', 'end': '18:00', 'total': '8h'},
      {'day': 'Fri', 'date': '2023-04-14', 'start': '08:00', 'end': '16:00', 'total': '8h'},
    ];

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: shifts.map((shift) => _buildShiftInfo(shift)).toList(),
        ),
      ),
    );
  }

  Widget _buildShiftInfo(Map<String, String> shift) {
    return Column(
      children: [
        Text(shift['day']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(shift['date']!),
        Text('${shift['start']} - ${shift['end']}'),
        Text('Total: ${shift['total']}'),
      ],
    );
  }
}
