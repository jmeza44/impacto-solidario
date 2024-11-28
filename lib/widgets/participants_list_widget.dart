import 'package:flutter/material.dart';
import '../models/participation.dart';
import '../services/authentication_service.dart';
import '../models/user.dart';
import 'feedback_display_widget.dart';

class ParticipantsListWidget extends StatelessWidget {
  final List<Participation> participants;
  final Function(String, AttendanceStatus) onAttendanceStatusChange;
  final AuthenticationService _authService = AuthenticationService();

  ParticipantsListWidget({
    super.key,
    required this.participants,
    required this.onAttendanceStatusChange,
  });

  Future<User?> _getUserProfile(String userId) async {
    try {
      final userProfile = await _authService.getUserProfile(userId);
      return User.fromMap(userProfile);
    } catch (_) {
      return null; // Return null if fetching fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participation = participants[index];
        return FutureBuilder<User?>(
          future: _getUserProfile(participation.volunteerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Cargando...'),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const ListTile(
                leading: Icon(Icons.error, color: Colors.red),
                title: Text('Error al cargar usuario'),
              );
            }

            final user = snapshot.data!;
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              radius: 24,
                              child: Text(
                                '${user.firstName[0]}${user.lastName[0]}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rol: ${user.role == UserRole.volunteer ? 'Voluntario' : 'Administrador'}',
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.green.shade400,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.phone ?? 'No disponible',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: Colors.blue.shade400,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.email ?? 'No disponible',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.orange.shade400,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Registrado: ${participation.registrationDate.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Estado: ${_getAttendanceStatusText(participation.attendanceStatus)}',
                          style: TextStyle(
                            color: _getAttendanceStatusColor(
                                participation.attendanceStatus),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Insert Feedback Widget here
                        FeedbackDisplayWidget(
                          volunteerId: participation.volunteerId,
                          activityId: participation.activityId,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<AttendanceStatus>(
                      onSelected: (status) {
                        onAttendanceStatusChange(
                            participation.volunteerId, status);
                      },
                      itemBuilder: (context) {
                        return AttendanceStatus.values.map((status) {
                          return PopupMenuItem<AttendanceStatus>(
                            value: status,
                            child: Text(
                              _getAttendanceStatusText(status),
                              style: TextStyle(
                                color: _getAttendanceStatusColor(status),
                              ),
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getAttendanceStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.attended:
        return 'Presente';
      case AttendanceStatus.absent:
        return 'Ausente';
      default:
        return 'Registrado';
    }
  }

  Color _getAttendanceStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.attended:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
