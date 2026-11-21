class ActivityRecord {
  final String id;
  final String habitName;
  final int durationMinutes;
  final String observation;
  final DateTime date;

  ActivityRecord({
    required this.id,
    required this.habitName,
    required this.durationMinutes,
    required this.observation,
    required this.date,
  });
}