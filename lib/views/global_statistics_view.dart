import 'package:flutter/material.dart';
import '../models/global_statistics.dart';
import '../services/statistics_service.dart';

class GlobalStatisticsView extends StatefulWidget {
  const GlobalStatisticsView({super.key});

  @override
  _GlobalStatisticsViewState createState() => _GlobalStatisticsViewState();
}

class _GlobalStatisticsViewState extends State<GlobalStatisticsView> {
  final StatisticsService _statisticsService = StatisticsService();
  late Future<GlobalStatistics> _globalStatsFuture;

  @override
  void initState() {
    super.initState();
    _globalStatsFuture = _statisticsService.getGlobalStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Globales'),
      ),
      body: FutureBuilder<GlobalStatistics>(
        future: _globalStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar estadísticas',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No se encontraron estadísticas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          GlobalStatistics stats = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Resumen de las estadísticas globales:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        icon: Icons.people,
                        title: 'Total de Voluntarios',
                        value: stats.totalVolunteers.toString(),
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        icon: Icons.event_available,
                        title: 'Actividades Realizadas',
                        value: stats.totalActivities.toString(),
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        icon: Icons.access_time_filled,
                        title: 'Horas de Servicio',
                        value: stats.totalServiceHours.toStringAsFixed(2),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
