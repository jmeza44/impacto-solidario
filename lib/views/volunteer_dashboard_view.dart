import 'package:flutter/material.dart';
import 'package:impacto_solidario/main.dart';

class VolunteerDashboardView extends StatelessWidget {
  const VolunteerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card for Profile
            _buildCard(
              context,
              title: 'Mi Perfil',
              description: 'Consulta y edita tu perfil de usuario.',
              icon: Icons.account_circle,
              onTap: () {
                Navigator.pushNamed(context, Routes.userProfile);
              },
            ),
            // Card for Activity List
            _buildCard(
              context,
              title: 'Mis Actividades',
              description:
                  'Consulta las actividades en las que has participado.',
              icon: Icons.event,
              onTap: () {
                Navigator.pushNamed(context, Routes.activityList);
              },
            ),
            // Card for Personal Statistics
            _buildCard(
              context,
              title: 'Mis Estadísticas',
              description:
                  'Consulta tus estadísticas personales de voluntariado.',
              icon: Icons.stacked_bar_chart,
              onTap: () {
                Navigator.pushNamed(context, Routes.globalStatistics);
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
