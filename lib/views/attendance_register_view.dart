import 'package:flutter/material.dart';
import '../services/participation_service.dart';
import '../models/participation.dart';

class AttendanceRegisterView extends StatefulWidget {
  final String activityId;

  const AttendanceRegisterView({super.key, required this.activityId});

  @override
  _AttendanceRegisterViewState createState() => _AttendanceRegisterViewState();
}

class _AttendanceRegisterViewState extends State<AttendanceRegisterView> {
  final ParticipationService _participationService = ParticipationService();
  List<Participation> _participants = [];
  final Map<String, bool> _attendanceStatus =
      {}; // To track the attendance status

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  // Fetch participants for the activity
  Future<void> _fetchParticipants() async {
    try {
      List<Participation> participants = await _participationService
          .getActivityParticipants(widget.activityId);
      setState(() {
        _participants = participants;
        // Initialize the attendance status map
        for (var participant in participants) {
          _attendanceStatus[participant.volunteerId] =
              participant.attendanceStatus == AttendanceStatus.attended;
        }
      });
    } catch (e) {
      print('Error fetching participants: $e');
    }
  }

  // Confirm attendance for each participant
  Future<void> _confirmAttendance() async {
    for (var participant in _participants) {
      AttendanceStatus status = _attendanceStatus[participant.volunteerId]!
          ? AttendanceStatus.attended
          : AttendanceStatus.absent;

      try {
        await _participationService.confirmAttendance(
          volunteerId: participant.volunteerId,
          activityId: widget.activityId,
          status: status,
        );
      } catch (e) {
        print('Error confirming attendance for ${participant.volunteerId}: $e');
      }
    }

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Asistencia confirmada con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Asistencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the list of participants
            Expanded(
              child: ListView.builder(
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  var participant = _participants[index];
                  return ListTile(
                    title: Text(participant.volunteerId),
                    subtitle: Text('Voluntario: ${participant.volunteerId}'),
                    trailing: Checkbox(
                      value: _attendanceStatus[participant.volunteerId],
                      onChanged: (bool? value) {
                        setState(() {
                          _attendanceStatus[participant.volunteerId] = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            // Button to confirm attendance
            ElevatedButton(
              onPressed: _confirmAttendance,
              child: const Text('Confirmar Asistencia'),
            ),
          ],
        ),
      ),
    );
  }
}
