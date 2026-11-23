import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';
import '../services/notification_service.dart';
import '../widgets/progress_canvas.dart';
import 'activity_form_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  List<Habit> _completedHabits = [];
  int _userPoints = 0;
  final TextEditingController _habitController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _loadData();
  }

  // --- PERSISTENCIA BLINDADA ---
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> habitsJson = prefs.getStringList('habits') ?? [];
      final List<String> completedJson =
          prefs.getStringList('completed_habits') ?? [];
      final int savedPoints = prefs.getInt('user_points') ?? 0;

      if (!mounted) return;
      setState(() {
        _userPoints = savedPoints;
        _habits = habitsJson.map((h) => Habit.fromJson(h)).toList();
        _completedHabits = completedJson.map((h) => Habit.fromJson(h)).toList();
      });
    } catch (e) {
      debugPrint('Error cargando datos locales: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> habitsJson = _habits.map((h) => h.toJson()).toList();
      final List<String> completedJson =
          _completedHabits.map((h) => h.toJson()).toList();

      await prefs.setStringList('habits', habitsJson);
      await prefs.setStringList('completed_habits', completedJson);
      await prefs.setInt('user_points', _userPoints);
    } catch (e) {
      debugPrint('Error guardando datos locales: $e');
    }
  }

  // --- CREAR / EDITAR HÁBITO CON RECORDATORIO ---
  void _showHabitModal({Habit? habitToEdit, int? index}) {
    final isEditing = habitToEdit != null;
    _habitController.text = isEditing ? habitToEdit.name : '';
    TimeOfDay? selectedTime =
        isEditing ? habitToEdit.reminderTimeOfDay : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                isEditing ? 'Editar Hábito' : 'Nuevo Hábito Consciente',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF311B92),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mantén tu racha diaria y supera los 7, 30 y 120 días para consolidarlo.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _habitController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '¿Qué hábito quieres construir?',
                  hintText: 'Ej. Leer 15 páginas antes de dormir',
                  filled: true,
                  fillColor: const Color(0xFFF5F3FF),
                  prefixIcon:
                      const Icon(Icons.spa_rounded, color: Color(0xFF7E57C2)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Selector de Recordatorio Diario
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded,
                        color: Color(0xFF7E57C2)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recordatorio diario',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF311B92),
                            ),
                          ),
                          Text(
                            selectedTime != null
                                ? 'Alerta todos los días a las ${selectedTime!.format(context)}'
                                : 'Sin alarma configurada',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (picked != null) {
                          setModalState(() => selectedTime = picked);
                        }
                      },
                      child: Text(
                        selectedTime != null ? 'Cambiar' : 'Elegir hora',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (selectedTime != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: Colors.grey),
                        tooltip: 'Quitar recordatorio',
                        onPressed: () =>
                            setModalState(() => selectedTime = null),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final name = _habitController.text.trim();
                  if (name.isEmpty) return;

                  late Habit targetHabit;

                  setState(() {
                    if (isEditing && index != null) {
                      targetHabit = _habits[index];
                      targetHabit.name = name;
                      targetHabit.reminderHour = selectedTime?.hour;
                      targetHabit.reminderMinute = selectedTime?.minute;
                    } else {
                      targetHabit = Habit(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        startDate: DateTime.now(),
                        reminderHour: selectedTime?.hour,
                        reminderMinute: selectedTime?.minute,
                      );
                      _habits.add(targetHabit);
                    }
                  });

                  // Programar o cancelar notificación local
                  if (selectedTime != null) {
                    await _notificationService.scheduleDailyHabitReminder(
                      habitId: targetHabit.id,
                      habitName: targetHabit.name,
                      time: selectedTime!,
                    );
                  } else {
                    await _notificationService
                        .cancelHabitReminder(targetHabit.id);
                  }

                  await _saveData();
                  _habitController.clear();
                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: Text(selectedTime != null
                          ? '⏰ Hábito guardado con recordatorio a las ${targetHabit.formattedReminderTime}'
                          : (isEditing
                              ? 'Hábito actualizado'
                              : '✨ ¡Hábito iniciado! Primera meta: 7 días')),
                      backgroundColor: const Color(0xFF5E35B1),
                    ),
                  );
                },
                child: Text(
                  isEditing ? 'Guardar Cambios' : 'Comenzar Camino',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ELIMINAR HÁBITO MANUALMENTE ---
  void _confirmDeleteHabit(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar hábito'),
        content: Text('¿Seguro que quieres eliminar "${_habits[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final removedId = _habits[index].id;
              setState(() {
                _habits.removeAt(index);
              });
              await _notificationService.cancelHabitReminder(removedId);
              await _saveData();
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // --- DIÁLOGO DE HÁBITO CONSCIENTE (120 DÍAS) ---
  void _showConsciousHabitDialog(String habitName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 70),
            SizedBox(height: 12),
            Text(
              '¡Enhorabuena!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        content: Text(
          'Has completado 120 días de "$habitName".\n\n'
          '¡Ya has creado un hábito consciente! Ganaste +500 puntos y este logro se guardó en tu Sala de Trofeos.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Genial, continuar!'),
          ),
        ],
      ),
    );
  }

  // --- COMPLETAR DÍA CON RACHA REAL (O SIMULACIÓN DE PRUEBA) ---
  Future<void> _incrementHabit(int index, {bool simulateNextDay = false}) async {
    final habit = _habits[index];

    if (!simulateNextDay && habit.isCompletedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
              '✅ Ya completaste "${habit.name}" hoy. ¡Vuelve mañana para mantener tu racha!'),
          backgroundColor: Colors.teal.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    bool completed120 = false;
    final String habitName = habit.name;
    final String habitId = habit.id;
    final now = DateTime.now();

    setState(() {
      if (simulateNextDay) {
        habit.currentStreak++;
      } else {
        if (habit.activeStreak > 0) {
          habit.currentStreak++;
        } else {
          habit.currentStreak = 1;
        }
        habit.lastCompletedDate = now;
      }

      habit.timesCompleted++;

      if (habit.timesCompleted >= 7 && !habit.claimed7) {
        habit.claimed7 = true;
        _userPoints += 50;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
                '🔥 ¡7 días en "$habitName"! +50 pts. Nueva meta: 30 días.'),
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (habit.timesCompleted >= 30 && !habit.claimed30) {
        habit.claimed30 = true;
        _userPoints += 150;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
                '🚀 ¡30 días en "$habitName"! +150 pts. Meta final: 120 días.'),
            backgroundColor: Colors.teal.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (habit.timesCompleted >= 120) {
        _userPoints += 500;
        habit.completedDate = now;
        _completedHabits.add(habit);
        _habits.removeAt(index);
        completed120 = true;
      }
    });

    if (completed120) {
      await _notificationService.cancelHabitReminder(habitId);
    }

    await _saveData();

    if (completed120 && mounted) {
      _showConsciousHabitDialog(habitName);
    }
  }

  int get _bestActiveStreak {
    if (_habits.isEmpty) return 0;
    int maxStreak = 0;
    for (final h in _habits) {
      final s = h.activeStreak;
      if (s > maxStreak) maxStreak = s;
    }
    return maxStreak;
  }

  Color _getStageColor(int target) {
    if (target == 120) return Colors.amber.shade700;
    if (target == 30) return Colors.teal.shade600;
    return const Color(0xFF7E57C2);
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      body: Column(
        children: [
          // --- CABECERA ESTILIZADA CON DEGRADADO ---
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5E35B1),
                  Color(0xFF7E57C2),
                  Color(0xFF9575CD),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x335E35B1),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'Ethereal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.18),
                          ),
                          icon: const Icon(Icons.emoji_events_rounded,
                              color: Colors.amber),
                          tooltip: 'Sala de Trofeos',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ActivityFormScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.18),
                          ),
                          icon: const Icon(Icons.person_rounded,
                              color: Colors.white),
                          tooltip: 'Mi Perfil',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  userPoints: _userPoints,
                                  consciousHabitsCount: _completedHabits.length,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.18),
                          ),
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.white),
                          tooltip: 'Cerrar sesión',
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Construye tu mejor versión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Completa tus hábitos cada día para mantener tu racha activa.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 18),

                // Tarjetas de resumen (Puntos, Mejor Racha, Conscientes)
                Row(
                  children: [
                    _buildStatBadge(
                      icon: Icons.stars_rounded,
                      iconColor: Colors.amber,
                      value: '$_userPoints',
                      label: 'Puntos',
                    ),
                    const SizedBox(width: 10),
                    _buildStatBadge(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: Colors.orangeAccent,
                      value: '${_bestActiveStreak}d',
                      label: 'Mejor Racha',
                    ),
                    const SizedBox(width: 10),
                    _buildStatBadge(
                      icon: Icons.workspace_premium_rounded,
                      iconColor: Colors.amberAccent,
                      value: '${_completedHabits.length}',
                      label: 'Conscientes',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- TÍTULO DE SECCIÓN ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tus Hábitos Activos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1B4E),
                  ),
                ),
                if (_habits.isNotEmpty)
                  Text(
                    '${_habits.where((h) => h.isCompletedToday).length}/${_habits.length} hoy',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // --- LISTA DE HÁBITOS ---
          Expanded(
            child: _habits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDE7F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.spa_rounded,
                              size: 64,
                              color: Color(0xFF7E57C2),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Comienza tu primer hábito',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF311B92),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Toca el botón "+ Nuevo Hábito" para iniciar tu camino hacia los 120 días.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final habit = _habits[index];
                      final target = habit.nextTargetDays;
                      final reward = habit.nextRewardPoints;
                      final stageColor = _getStageColor(target);
                      final doneToday = habit.isCompletedToday;
                      final streak = habit.activeStreak;
                      final progressRatio =
                          (habit.timesCompleted / target).clamp(0.0, 1.0);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: doneToday
                              ? const Color(0xFFF1F8F6)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: doneToday
                              ? Border.all(
                                  color: Colors.teal.shade200, width: 1.2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  HabitProgressIndicator(
                                      progress: habit.timesCompleted),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: stageColor
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${habit.stageLabel} • +$reward pts',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: stageColor,
                                                ),
                                              ),
                                            ),
                                            if (streak > 0)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .local_fire_department_rounded,
                                                      size: 13,
                                                      color: Colors.deepOrange,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '$streak ${streak == 1 ? 'día' : 'días'}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.deepOrange,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (habit.hasReminder)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFEDE7F6),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.alarm_rounded,
                                                      size: 13,
                                                      color: Color(0xFF5E35B1),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      habit
                                                          .formattedReminderTime,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF5E35B1),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          habit.name,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: doneToday
                                                ? Colors.teal.shade900
                                                : const Color(0xFF1F1633),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          doneToday
                                              ? '¡Completado por hoy! (${habit.timesCompleted}/$target días)'
                                              : '${habit.timesCompleted} de $target días completados',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: doneToday
                                                ? Colors.teal.shade700
                                                : Colors.grey.shade600,
                                            fontWeight: doneToday
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Material(
                                    color: doneToday
                                        ? Colors.teal.shade600
                                        : stageColor.withOpacity(0.12),
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () => _incrementHabit(index),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Icon(
                                          doneToday
                                              ? Icons.done_all_rounded
                                              : Icons.check_rounded,
                                          color: doneToday
                                              ? Colors.white
                                              : stageColor,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded,
                                        color: Colors.grey.shade500),
                                    onSelected: (value) {
                                      if (value == 'simulate') {
                                        _incrementHabit(index,
                                            simulateNextDay: true);
                                      } else if (value == 'edit') {
                                        _showHabitModal(
                                            habitToEdit: habit, index: index);
                                      } else if (value == 'delete') {
                                        _confirmDeleteHabit(index);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'simulate',
                                        child: Row(
                                          children: [
                                            Icon(Icons.bolt_rounded,
                                                color: Colors.amber, size: 18),
                                            SizedBox(width: 8),
                                            Text('Simular +1 día (Prueba)'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_rounded, size: 18),
                                            SizedBox(width: 8),
                                            Text('Editar hábito / hora'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded,
                                                color: Colors.redAccent,
                                                size: 18),
                                            SizedBox(width: 8),
                                            Text('Eliminar',
                                                style: TextStyle(
                                                    color: Colors.redAccent)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progressRatio,
                                  minHeight: 7,
                                  backgroundColor: Colors.grey.shade100,
                                  color: doneToday
                                      ? Colors.teal.shade500
                                      : stageColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF673AB7),
        elevation: 4,
        onPressed: () => _showHabitModal(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nuevo Hábito',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}