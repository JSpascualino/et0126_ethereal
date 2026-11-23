import 'dart:convert';
import 'package:flutter/material.dart';

class Habit {
  String id;
  String name;
  DateTime startDate;
  DateTime? completedDate;
  DateTime? lastCompletedDate;
  int timesCompleted;
  int currentStreak;
  bool claimed7;
  bool claimed30;
  int? reminderHour;
  int? reminderMinute;

  Habit({
    required this.id,
    required this.name,
    required this.startDate,
    this.completedDate,
    this.lastCompletedDate,
    this.timesCompleted = 0,
    this.currentStreak = 0,
    this.claimed7 = false,
    this.claimed30 = false,
    this.reminderHour,
    this.reminderMinute,
  });

  bool get hasReminder => reminderHour != null && reminderMinute != null;

  TimeOfDay? get reminderTimeOfDay => hasReminder
      ? TimeOfDay(hour: reminderHour!, minute: reminderMinute!)
      : null;

  String get formattedReminderTime {
    if (!hasReminder) return '';
    final h = reminderHour!.toString().padLeft(2, '0');
    final m = reminderMinute!.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    return lastCompletedDate!.year == now.year &&
        lastCompletedDate!.month == now.month &&
        lastCompletedDate!.day == now.day;
  }

  int get activeStreak {
    if (lastCompletedDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );
    final difference = today.difference(lastDay).inDays;
    return difference <= 1 ? currentStreak : 0;
  }

  int get nextTargetDays {
    if (timesCompleted < 7) return 7;
    if (timesCompleted < 30) return 30;
    return 120;
  }

  int get nextRewardPoints {
    if (timesCompleted < 7) return 50;
    if (timesCompleted < 30) return 150;
    return 500;
  }

  String get stageLabel {
    if (timesCompleted < 7) return 'Etapa 1: Arranque';
    if (timesCompleted < 30) return 'Etapa 2: Constancia';
    return 'Etapa 3: Maestría';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'timesCompleted': timesCompleted,
      'currentStreak': currentStreak,
      'claimed7': claimed7,
      'claimed30': claimed30,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'])
          : null,
      lastCompletedDate: map['lastCompletedDate'] != null
          ? DateTime.parse(map['lastCompletedDate'])
          : null,
      timesCompleted: map['timesCompleted'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      claimed7: map['claimed7'] ?? false,
      claimed30: map['claimed30'] ?? false,
      reminderHour: map['reminderHour'],
      reminderMinute: map['reminderMinute'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source));
}