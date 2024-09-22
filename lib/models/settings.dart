class Settings {
  final double defaultHourlyRate;
  final int defaultBreakDuration;
  final String currency;
  final String language;
  final String theme;

  Settings({
    required this.defaultHourlyRate,
    required this.defaultBreakDuration,
    required this.currency,
    required this.language,
    required this.theme,
  });
}