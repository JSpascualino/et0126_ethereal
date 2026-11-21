import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../models/activity_record.dart';
import '../services/activity_service.dart';

class ActivityFormScreen extends StatefulWidget {
  const ActivityFormScreen({super.key});

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  // 1. Llave del formulario y Controladores
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _observationController = TextEditingController();

  // 2. Instancia del servicio y estados de la UI
  final ActivityService _service = ActivityService();
  List<ActivityRecord> _records = [];
  bool _isLoadingList = true;
  bool _isSaving = false;

  // 3. Cargar datos iniciales sin llamar al servicio desde build()
  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  // 4. Liberar memoria al salir
  @override
  void dispose() {
    _habitNameController.dispose();
    _durationController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await _service.getRecords();
      if (mounted) {
        setState(() {
          _records = records;
          _isLoadingList = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingList = false);
      }
    }
  }

  // Función para guardar con protección de doble envío y try-catch-finally
  Future<void> _saveRecord() async {
    // Valida los campos. Si hay error, se detiene.
    if (!_formKey.currentState!.validate()) return;

    // Marca como ocupado para evitar envíos repetidos
    setState(() => _isSaving = true);

    try {
      final newRecord = ActivityRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitName: _habitNameController.text.trim(),
        durationMinutes: int.parse(_durationController.text.trim()),
        observation: _observationController.text.trim(),
        date: DateTime.now(),
      );

      // Espera el resultado del servicio
      final savedRecord = await _service.createRecord(newRecord);

      if (mounted) {
        // Actualiza la lista, limpia el formulario y muestra confirmación
        setState(() {
          _records = [savedRecord, ..._records];
          _habitNameController.clear();
          _durationController.clear();
          _observationController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Actividad registrada con éxito!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // Si el servicio rechaza la regla de negocio, muestra el error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      // En cualquier caso, termina el estado de carga
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // VALIDACIONES
  final nameValidator = MultiValidator([
    RequiredValidator(errorText: 'Escribe el nombre del hábito.'),
    MinLengthValidator(3, errorText: 'Usa al menos 3 caracteres.'),
  ]);

  // Regla de dominio: La duración debe ser mayor a 0
  String? durationValidator(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa los minutos.';
    final number = int.tryParse(value);
    if (number == null) return 'Debe ser un número.';
    if (number <= 0) return 'La duración debe ser mayor a 0.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Actividad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- FORMULARIO ---
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _habitNameController,
                    decoration: const InputDecoration(labelText: 'Hábito a registrar', border: OutlineInputBorder()),
                    validator: nameValidator,
                    enabled: !_isSaving, // Deshabilita si está guardando
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(labelText: 'Minutos', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: durationValidator,
                          enabled: !_isSaving,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _observationController,
                          decoration: const InputDecoration(labelText: '¿Cómo te sentiste?', border: OutlineInputBorder()),
                          validator: RequiredValidator(errorText: 'Obligatorio'),
                          enabled: !_isSaving,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón de guardar con estado de carga
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveRecord,
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Guardar Actividad'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 40, thickness: 2),

            // --- LISTA DE REGISTROS ---
            Expanded(
              child: _isLoadingList
                  ? const Center(child: CircularProgressIndicator())
                  : _records.isEmpty
                      ? const Center(child: Text('No hay actividades. ¡Registra la primera!'))
                      : ListView.builder(
                          itemCount: _records.length,
                          itemBuilder: (context, index) {
                            final record = _records[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.purple),
                                title: Text(record.habitName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(record.observation),
                                trailing: Text('${record.durationMinutes} min'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}