import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/shift_service.dart';
import '../models/shift.dart';

class ShiftManagerScreen extends StatefulWidget {
  const ShiftManagerScreen({Key? key}) : super(key: key);

  @override
  _ShiftManagerScreenState createState() => _ShiftManagerScreenState();
}

class _ShiftManagerScreenState extends State<ShiftManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shift Manager')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _startTime = picked;
                  });
                }
              },
              child: const Text('Pick start date'),
            ),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null && _startTime != null) {
                  setState(() {
                    _startTime = DateTime(
                      _startTime!.year,
                      _startTime!.month,
                      _startTime!.day,
                      picked.hour,
                      picked.minute,
                    );
                  });
                }
              },
              child: const Text('Pick start time'),
            ),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null && _startTime != null) {
                  setState(() {
                    _endTime = DateTime(
                      _startTime!.year,
                      _startTime!.month,
                      _startTime!.day,
                      picked.hour,
                      picked.minute,
                    );
                  });
                }
              },
              child: const Text('Pick end time'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && _startTime != null && _endTime != null) {
                  final shift = Shift(startTime: _startTime!, endTime: _endTime!);
                  Provider.of<ShiftService>(context, listen: false).addShift(shift);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift added')));
                }
              },
              child: const Text('Add Shift'),
            ),
          ],
        ),
      ),
    );
  }
}