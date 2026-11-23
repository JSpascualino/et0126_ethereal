import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';

class ActivityFormScreen extends StatefulWidget {
  const ActivityFormScreen({Key? key}) : super(key: key);

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  List<Habit> _completedHabits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedHabits();
  }

  Future<void> _loadCompletedHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? completedJson = prefs.getStringList('completed_habits');

    setState(() {
      if (completedJson != null) {
        _completedHabits =
            completedJson.map((h) => Habit.fromJson(h)).toList().reversed.toList();
      }
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hábitos Conscientes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFB39DDB),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _completedHabits.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 90,
                          color: Colors.amber.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tu Sala de Trofeos está vacía',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4527A0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Completa 120 días de cualquier hábito en la pantalla principal para forjar un hábito consciente y exhibirlo aquí.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium,
                              color: Colors.amber, size: 44),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_completedHabits.length} ${_completedHabits.length == 1 ? 'Hábito Consciente' : 'Hábitos Conscientes'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '120 días de disciplina superados con éxito.',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _completedHabits.length,
                        itemBuilder: (context, index) {
                          final habit = _completedHabits[index];
                          final endDate = habit.completedDate ?? DateTime.now();

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                  color: Colors.amber.shade300, width: 1.5),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              leading: CircleAvatar(
                                backgroundColor: Colors.amber.shade100,
                                radius: 26,
                                child: Icon(
                                  Icons.emoji_events_rounded,
                                  color: Colors.amber.shade800,
                                  size: 30,
                                ),
                              ),
                              title: Text(
                                habit.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Iniciado: ${_formatDate(habit.startDate)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Consolidado: ${_formatDate(endDate)} (120 días)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+700 pts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}