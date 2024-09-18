
class Shift {
  final DateTime startTime;
  final DateTime endTime;

  Shift({required this.startTime, required this.endTime});

  Duration get duration => endTime.difference(startTime);
}
