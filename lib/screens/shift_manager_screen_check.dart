// File: lib/screens/shift_manager_screen.dart

import 'package:flutter/material.dart';
import 'app_state.dart';  // or wherever your main Shift class is defined
import 'services/shift_service.dart';

class ShiftManagerScreen extends StatefulWidget {
  @override
  _ShiftManagerScreenState createState() => _ShiftManagerScreenState();
}

class _ShiftManagerScreenState extends State<ShiftManagerScreen> {
  final ShiftService _shiftService = ShiftService();
  List<Shift> _shifts = [];

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    List<Shift> shifts = await _shiftService.getAllShifts();
    setState(() {
      _shifts = shifts;
    });
  }

  void _addNoteToShift(Shift shift) async {
    String? note = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController _noteController = TextEditingController();
        return AlertDialog(
          title: Text('Add Note to Shift'),
          content: TextField(
            controller: _noteController,
            decoration: InputDecoration(hintText: 'Enter note here'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(_noteController.text);
              },
            ),
          ],
        );
      },
    );

    if (note != null && note.isNotEmpty) {
      shift.note = note;
      await _shiftService.updateShift(shift);
      _loadShifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shift Manager'),
      ),
      body: ListView.builder(
        itemCount: _shifts.length,
        itemBuilder: (context, index) {
          Shift shift = _shifts[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('Shift: ${shift.name}'),
              subtitle: Text('Date: ${shift.date} - Note: ${shift.note ?? 'No notes'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Edit shift functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Delete shift functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.note_add, color: Colors.green),
                    onPressed: () => _addNoteToShift(shift),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add new shift functionality
        },
      ),
    );
  }
}