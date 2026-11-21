import '../models/activity_record.dart';

class ActivityService {
  // Lista privada en memoria (se borra al reiniciar la app, tal como pide el taller)
  static final List<ActivityRecord> _records = [];

  // Simula obtener la lista de registros con una demora de 500ms
  Future<List<ActivityRecord>> getRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<ActivityRecord>.unmodifiable(_records);
  }

  // Simula guardar un nuevo registro con una demora de 1 segundo
  Future<ActivityRecord> createRecord(ActivityRecord record) async {
    await Future.delayed(const Duration(seconds: 1));

    // Regla de negocio: Evitar duplicados del mismo hábito en el mismo día
    final existe = _records.any((actual) => 
      actual.habitName.toLowerCase() == record.habitName.toLowerCase() &&
      actual.date.year == record.date.year &&
      actual.date.month == record.date.month &&
      actual.date.day == record.date.day
    );

    if (existe) {
      throw StateError('Error: Ya registraste actividad para este hábito hoy.');
    }

    // Si todo está bien, lo agrega al inicio de la lista
    _records.insert(0, record);
    return record;
  }
}