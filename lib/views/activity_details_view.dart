import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../models/participation.dart';
import '../models/user.dart';
import '../services/activity_service.dart';
import '../services/participation_service.dart';
import '../services/shared_preferences_service.dart';
import '../widgets/participants_list_widget.dart';
import '../widgets/volunteer_status_widget.dart';
import 'create_edit_activity_view.dart';
import 'feedback_view.dart';

class ActivityDetailsView extends StatefulWidget {
  final String activityId;

  const ActivityDetailsView({super.key, required this.activityId});

  @override
  _ActivityDetailsViewState createState() => _ActivityDetailsViewState();
}

class _ActivityDetailsViewState extends State<ActivityDetailsView> {
  late ActivityService _activityService;
  late ParticipationService _participationService;
  late SharedPreferencesService _sharedPreferencesService;

  Activity? _activity;
  List<Participation> _participants = [];
  String? _userId;
  String? _userRole;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService();
    _participationService = ParticipationService();
    _sharedPreferencesService = SharedPreferencesService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      var session = await _sharedPreferencesService.getUserSession();
      _userId = session['userId'] ?? '';
      _userRole = session['role'] ?? '';

      _activity = await _activityService.getActivityDetails(widget.activityId);
      _participants = await _participationService
          .getActivityParticipants(widget.activityId);

      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading activity data: $e');
      setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  AttendanceStatus _getVolunteerStatus() {
    final participation = _participants.firstWhere(
      (p) => p.volunteerId == _userId,
      orElse: () => Participation(
        volunteerId: '',
        activityId: '',
        attendanceStatus: AttendanceStatus.absent,
        id: '',
        registrationDate: DateTime.now(),
      ),
    );
    return participation.attendanceStatus;
  }

  Widget _buildActivityDetails() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activity!.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _activity!.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Fecha: ${_formatDate(_activity!.date)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis, // Handle overflow
                      softWrap: true, // Allow wrapping
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Hora: ${DateFormat('HH:mm').format(_activity!.date)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      // Prevent overflow for time
                      softWrap: true, // Allow wrapping for time
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  // Ensure the location text wraps properly within available space
                  child: Text(
                    "Ubicación: ${_activity!.location}",
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true, // Allow wrapping for location
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.category, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Categoría: ${_activity!.category}",
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  // Handle overflow for category
                  softWrap: true, // Allow wrapping for category
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Participantes: ${_participants.length}/${_activity!.maxVolunteers}",
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  // Prevent overflow for participants
                  softWrap: true, // Allow wrapping for participants count
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando actividad...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_activity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No se encontró la actividad.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_activity!.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityDetails(),
            const SizedBox(height: 20),
            if (_userRole == UserRole.volunteer.name) ...[
              VolunteerStatusWidget(status: _getVolunteerStatus()),
              const SizedBox(height: 20),
              if (_getVolunteerStatus() == AttendanceStatus.absent)
                ElevatedButton.icon(
                  onPressed: () async {
                    await _participationService.registerForActivity(
                      volunteerId: _userId!,
                      activityId: widget.activityId,
                    );
                    await _loadData();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Inscribirse'),
                ),
              // Add Feedback button if the volunteer attended
              if (_getVolunteerStatus() == AttendanceStatus.attended)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FeedbackView(activityId: widget.activityId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(overlayColor: Colors.green),
                  child: const Text('Calificar Actividad'),
                ),
            ],
            if (_userRole == UserRole.administrator.name) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateEditActivityView(activityId: _activity!.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar actividad'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _activityService.deleteActivity(widget.activityId);
                      Navigator.pop(context); // Navigate back after delete
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar actividad'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      overlayColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ParticipantsListWidget(
                participants: _participants,
                onAttendanceStatusChange: (id, status) async {
                  await _participationService.confirmAttendance(
                    volunteerId: id,
                    activityId: widget.activityId,
                    status: status,
                  );
                  await _loadData();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
