import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/activity_service.dart';
import '../services/shared_preferences_service.dart';
import '../models/activity.dart';

class CreateEditActivityView extends StatefulWidget {
  final String? activityId;

  const CreateEditActivityView({super.key, this.activityId});

  @override
  _CreateEditActivityViewState createState() => _CreateEditActivityViewState();
}

class _CreateEditActivityViewState extends State<CreateEditActivityView> {
  late ActivityService _activityService;
  late SharedPreferencesService _sharedPreferencesService;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _maxVolunteersController;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Educación'; // Default category
  bool _isEditing = false;
  late Activity _activity;

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService();
    _sharedPreferencesService = SharedPreferencesService();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _maxVolunteersController = TextEditingController();

    if (widget.activityId != null) {
      _isEditing = true;
      _loadActivityData();
    }
  }

  Future<void> _loadActivityData() async {
    try {
      _activity = await _activityService.getActivityDetails(widget.activityId!);
      _titleController.text = _activity.title;
      _descriptionController.text = _activity.description;
      _locationController.text = _activity.location;
      _maxVolunteersController.text = _activity.maxVolunteers.toString();
      _selectedDate = _activity.date;
      _selectedCategory = _activity.category;
      setState(() {});
    } catch (e) {
      print('Error loading activity data: $e');
    }
  }

  // Save or update the activity
  Future<void> _saveActivity() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final location = _locationController.text;
    final maxVolunteers = int.tryParse(_maxVolunteersController.text) ?? 0;

    if (_isEditing) {
      await _activityService.updateActivity(
        activityId: _activity.id,
        title: title,
        description: description,
        date: _selectedDate,
        location: location,
        category: _selectedCategory,
        maxVolunteers: maxVolunteers,
      );
    } else {
      var session = await _sharedPreferencesService.getUserSession();
      String creatorId = session['userId'] ?? '';
      await _activityService.createActivity(
        title: title,
        description: description,
        date: _selectedDate,
        location: location,
        category: _selectedCategory,
        maxVolunteers: maxVolunteers,
        creatorId: creatorId,
      );
    }
    Navigator.pop(context); // Go back after saving or updating
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Actividad' : 'Crear Actividad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la actividad',
                  hintText: 'Ingresa el título',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe la actividad',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  hintText: 'Ubicación de la actividad',
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha y Hora',
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: <String>['Educación', 'Salud', 'Medio Ambiente']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _maxVolunteersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número máximo de voluntarios',
                  hintText: 'Ingresa el número máximo',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveActivity,
                child: Text(
                    _isEditing ? 'Actualizar Actividad' : 'Crear Actividad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
