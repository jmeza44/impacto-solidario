import 'package:flutter/material.dart';
import '../models/participation.dart';

class VolunteerStatusWidget extends StatelessWidget {
  final AttendanceStatus status;

  const VolunteerStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AttendanceStatus.registered:
        return const Text('Estado de inscripción: Registrado');
      case AttendanceStatus.attended:
        return const Text('Estado de asistencia: Asistió');
      case AttendanceStatus.absent:
        return const Text('Estado de asistencia: Ausente');
      default:
        return const Text('Estado de inscripción: No registrado');
    }
  }
}
