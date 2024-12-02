import 'package:flutter/material.dart';
import '../models/shift.dart';
import 'package:intl/intl.dart';

class UpcomingShiftCard extends StatelessWidget {
  final Shift shift;

  const UpcomingShiftCard({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building UpcomingShiftCard for ${shift.startTime}');
    return Card(
      child: ListTile(
        title: Text(DateFormat('EEEE, MMMM d').format(shift.startTime)),
        subtitle: Text(
          '${DateFormat('HH:mm').format(shift.startTime)} - ${DateFormat('HH:mm').format(shift.endTime)}',
        ),
        trailing: Text(
          '${shift.duration.inHours}h ${shift.duration.inMinutes % 60}m',
        ),
      ),
    );
  }
}