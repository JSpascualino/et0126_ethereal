import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';
import '../widgets/progress_canvas.dart';
import 'activity_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  final TextEditingController _habitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  // --- PERSISTENCIA (SharedPreferences) ---
  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? habitsJson = prefs.getStringList('habits');
    if (habitsJson != null) {
      setState(() {
        _habits = habitsJson.map((h) => Habit.fromJson(h)).toList();
      });
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> habitsJson = _habits.map((h) => h.toJson()).toList();
    await prefs.setStringList('habits', habitsJson);
  }

  // --- LÓGICA DE LA INTERFAZ ---
  void _addHabit(String name) {
    if (name.trim().isEmpty) return; // Validación básica

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      startDate: DateTime.now(),
    );

    setState(() {
      _habits.add(newHabit);
    });
    
    _saveHabits();
    _habitController.clear();
    Navigator.pop(context); // Cierra el modal

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Hábito creado con éxito!'), backgroundColor: Color(0xFFB39DDB)),
    );
  }

  void _incrementHabit(int index) {
    setState(() {
      _habits[index].timesCompleted++;
    });
    _saveHabits();
  }

  // --- UI: Modal para nuevo hábito ---
  void _showAddHabitModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nuevo Hábito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _habitController,
              decoration: const InputDecoration(
                hintText: 'Ej. Beber 2L de agua',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB39DDB)),
              onPressed: () => _addHabit(_habitController.text),
              child: const Text('Guardar Hábito', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethereal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB39DDB),
        // ACÁ ESTÁ EL NUEVO BOTÓN QUE LLEVA AL FORMULARIO
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Registro de Actividad',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivityFormScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Sección de bienvenida (Stateless)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¡Bienvenido!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Construye tu nuevo estilo de vida, un paso a la vez.'),
                    ],
                  ),
                ),
                Icon(Icons.auto_awesome, color: Colors.orange.shade300, size: 40),
              ],
            ),
          ),
          
          // Lista de hábitos o estado vacío
          Expanded(
            child: _habits.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Aún no tienes hábitos.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        Text('¡Crea uno para empezar!'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final habit = _habits[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          // Aquí usamos nuestro Canvas personalizado
                          leading: HabitProgressIndicator(progress: habit.timesCompleted),
                          title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Racha: ${habit.timesCompleted} veces'),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Color(0xFFB39DDB)),
                            onPressed: () => _incrementHabit(index), // Control interactivo
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB39DDB),
        onPressed: _showAddHabitModal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}