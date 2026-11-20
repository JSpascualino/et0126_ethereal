import 'dart:convert';

class Habit {
  final String id;
  final String name;
  final String category;
  int timesCompleted;
  final DateTime startDate;
  Set<String> tags;
  String? notes;

  Habit({
    required this.id,
    required this.name,
    this.category = 'General',
    this.timesCompleted = 0,
    required this.startDate,
    this.tags = const {},
    this.notes,
  });

  // Uso de while: calcula el nivel aumentando la dificultad progresivamente
  int calculateLevel() {
    int level = 1;
    int currentPoints = timesCompleted;
    int pointsForNextLevel = 5;

    while (currentPoints >= pointsForNextLevel) {
      level++;
      currentPoints -= pointsForNextLevel;
      pointsForNextLevel += 2;
    }
    return level;
  }

  // Uso de for: suma el total de puntos invertidos hasta el nivel actual
  int totalPointsInvested() {
    int total = 0;
    for (int i = 1; i < calculateLevel(); i++) {
      total += 5 + ((i - 1) * 2);
    }
    return total;
  }

  // Para guardar en SharedPreferences (Uso de Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'timesCompleted': timesCompleted,
      'startDate': startDate.toIso8601String(),
      'tags': tags.toList(),
      'notes': notes,
    };
  }

  // Para leer de SharedPreferences
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? 'General',
      timesCompleted: map['timesCompleted'],
      startDate: DateTime.parse(map['startDate']),
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {},
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());
  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source));
}