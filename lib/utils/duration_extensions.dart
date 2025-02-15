extension DurationExtensions on Duration {
  double toHours() {
    return inMinutes / 60.0;
  }
}
