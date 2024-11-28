import 'package:flutter/material.dart';
import 'package:impacto_solidario/models/user.dart';
import 'package:impacto_solidario/models/participation_history.dart';
import 'package:impacto_solidario/services/authentication_service.dart';
import 'package:impacto_solidario/services/shared_preferences_service.dart';
import 'package:impacto_solidario/services/participation_service.dart';
import 'package:impacto_solidario/services/activity_service.dart';
import 'package:impacto_solidario/models/activity.dart';
import 'package:intl/intl.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final AuthenticationService _authService = AuthenticationService();
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  final ParticipationService _participationService = ParticipationService();
  final ActivityService _activityService = ActivityService();

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _role = '';
  String _userId = '';
  bool _isLoading = true;
  List<Activity> _participatedOn = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userSession = await _prefsService.getUserSession();
      if (userSession.isEmpty) {
        throw Exception("Usuario no autenticado.");
      }

      _userId = userSession['userId']!;
      _role = userSession['role']!;

      final userProfile = await _authService.getUserProfile(_userId);
      // Fetch participation history
      final participations =
          await _participationService.getParticipatedActivities(_userId);

      setState(() {
        _firstName = userProfile['firstName'];
        _lastName = userProfile['lastName'];
        _email = userProfile['email'];
        _phone = userProfile['phone'];
        _participatedOn = participations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: $_firstName $_lastName',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Correo: $_email', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Teléfono: $_phone',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  if (_role == UserRole.volunteer.name) ...[
                    const Text('Historial de Actividades',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _participatedOn.isEmpty
                        ? const Text("No tienes actividades registradas.")
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _participatedOn.length,
                              itemBuilder: (context, index) {
                                var activity = _participatedOn[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(activity.title ??
                                        'Actividad desconocida'),
                                    subtitle: Text(
                                      'Fecha: ${DateFormat('dd/MM/yyyy').format(activity.date) ?? 'No disponible'}\n'
                                      'Hora: ${DateFormat('HH:mm').format(activity.date) ?? 'No disponible'}\n'
                                      'Descripción: ${activity.description ?? 'No disponible'}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Text(
                                      'Estado: ${activity.status == ActivityStatus.active ? 'Activa' : activity.status == ActivityStatus.canceled ? 'Cancelada' : 'Finalizada'}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: activity.status ==
                                                  ActivityStatus.active
                                              ? Colors.cyan
                                              : activity.status ==
                                                      ActivityStatus.canceled
                                                  ? Colors.red
                                                  : Colors.green),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ] else if (_role == UserRole.administrator.name) ...[
                    const Text('Rol: Administrador',
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _editProfile,
                      child: const Text('Editar Perfil'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _editProfile() async {
    // Open profile edit screen (not implemented here)
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Editar perfil')));
  }
}
