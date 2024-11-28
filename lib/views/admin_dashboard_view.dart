import 'package:flutter/material.dart';
import 'package:impacto_solidario/main.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card for Global Statistics
            _buildCard(
              context,
              title: 'Estadísticas Globales',
              description:
                  'Accede a las estadísticas globales de los voluntarios y actividades.',
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.pushNamed(context, Routes.globalStatistics);
              },
            ),
            // Card for Activity List
            _buildCard(
              context,
              title: 'Lista de Actividades',
              description:
                  'Gestiona y consulta todas las actividades realizadas.',
              icon: Icons.list,
              onTap: () {
                Navigator.pushNamed(context, Routes.activityList);
              },
            ),
            // Card for Attendance Management
            _buildCard(
              context,
              title: 'Registro de Asistencia',
              description:
                  'Gestiona el registro de asistencia de los voluntarios.',
              icon: Icons.assignment,
              onTap: () {
                Navigator.pushNamed(context, Routes.attendanceRegister);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required Function() onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }
}
