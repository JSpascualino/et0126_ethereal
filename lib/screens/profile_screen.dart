import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final int userPoints;
  final int consciousHabitsCount;

  const ProfileScreen({
    Key? key,
    required this.userPoints,
    required this.consciousHabitsCount,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  int _selectedAvatarIndex = 0;
  bool _isSaving = false;

  // Catálogo de avatares temáticos (Línea corregida)
final _avatars = [
    {'icon': Icons.spa_rounded, 'color': const Color(0xFF7E57C2)},
    {'icon': Icons.auto_awesome_rounded, 'color': const Color(0xFFFFB300)},
    {'icon': Icons.self_improvement_rounded, 'color': const Color(0xFF00897B)},
    {'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFE53935)},
    {'icon': Icons.psychology_rounded, 'color': const Color(0xFF3949AB)},
    {'icon': Icons.wb_sunny_rounded, 'color': const Color(0xFFFB8C00)},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final String uid = _user?.uid ?? 'default';

    if (!mounted) return;
    setState(() {
      _nameController.text = _user?.displayName ??
          prefs.getString('profile_name_$uid') ??
          'Explorador Ethereal';
      _bioController.text = prefs.getString('profile_bio_$uid') ??
          'Construyendo hábitos conscientes día a día.';
      _selectedAvatarIndex = prefs.getInt('profile_avatar_$uid') ?? 0;
    });
  }

  Future<void> _saveProfileData() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String uid = _user?.uid ?? 'default';

      await _user?.updateDisplayName(name);
      await prefs.setString('profile_name_$uid', name);
      await prefs.setString('profile_bio_$uid', bio);
      await prefs.setInt('profile_avatar_$uid', _selectedAvatarIndex);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('✅ Perfil actualizado correctamente'),
          backgroundColor: const Color(0xFF5E35B1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar perfil: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- ELIMINACIÓN SEGURA DE CUENTA ---
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Eliminar cuenta'),
          ],
        ),
        content: const Text(
          'Esta acción es permanente. Se borrarán tu cuenta de Firebase, tus puntos, tus hábitos activos y tu Sala de Trofeos.\n\n¿Estás completamente seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              _executeAccountDeletion();
            },
            child: const Text('Sí, eliminar todo'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeAccountDeletion({String? password}) async {
    if (_user == null) return;

    try {
      if (password != null && _user!.email != null) {
        final cred = EmailAuthProvider.credential(
          email: _user!.email!,
          password: password,
        );
        await _user!.reauthenticateWithCredential(cred);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await _user!.delete();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showReauthDialog();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo eliminar la cuenta: ${e.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showReauthDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmación de seguridad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Por seguridad, ingresa tu contraseña actual para confirmar la eliminación definitiva de tu cuenta:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              final pass = passwordController.text;
              Navigator.pop(context);
              if (pass.isNotEmpty) {
                _executeAccountDeletion(password: pass);
              }
            },
            child: const Text('Confirmar y eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAvatar = _avatars[_selectedAvatarIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5E35B1),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- CABECERA DE AVATAR ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor:
                          (currentAvatar['color'] as Color).withOpacity(0.15),
                      child: Icon(
                        currentAvatar['icon'] as IconData,
                        size: 46,
                        color: currentAvatar['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user?.email ?? 'usuario@ethereal.app',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selector rápido de avatares
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_avatars.length, (index) {
                      final isSelected = index == _selectedAvatarIndex;
                      final item = _avatars[index];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedAvatarIndex = index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.amber, width: 2.5)
                                : null,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected
                                ? item['color'] as Color
                                : Colors.white,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- TARJETA DE ESTADÍSTICAS ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProfileStat(
                          Icons.stars_rounded,
                          Colors.amber,
                          '${widget.userPoints}',
                          'Puntos Totales',
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        _buildProfileStat(
                          Icons.emoji_events_rounded,
                          const Color(0xFF7E57C2),
                          '${widget.consciousHabitsCount}',
                          'Hábitos Conscientes',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // --- FORMULARIO DE IDENTIDAD ---
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1B4E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre o apodo',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: Color(0xFF7E57C2)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Tu propósito o biografía',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.edit_note_rounded,
                            color: Color(0xFF7E57C2)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveProfileData,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 12),

                  // --- ZONA DE PELIGRO ---
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _confirmDeleteAccount,
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text(
                      'Eliminar mi cuenta permanentemente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(
      IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1B4E),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}