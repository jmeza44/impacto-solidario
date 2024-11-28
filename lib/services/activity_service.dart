import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/activity.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create an activity
  Future<String> createActivity({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String category,
    required int maxVolunteers,
    required String creatorId,
  }) async {
    try {
      String activityId = _firestore
          .collection('activities')
          .doc()
          .id; // Generate a new document ID
      Activity newActivity = Activity(
        id: activityId,
        title: title,
        description: description,
        date: date,
        location: location,
        category: category,
        maxVolunteers: maxVolunteers,
        status: ActivityStatus.active,
        // Default status is active
        creatorId: creatorId,
        creationDate: DateTime.now(),
        lastUpdateDate: DateTime.now(),
      );

      // Save the activity to Firestore
      await _firestore
          .collection('activities')
          .doc(activityId)
          .set(newActivity.toMap());
      return activityId;
    } catch (e) {
      throw Exception("Failed to create activity: $e");
    }
  }

  // Update an activity
  Future<void> updateActivity({
    required String activityId,
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String category,
    required int maxVolunteers,
  }) async {
    try {
      // Fetch the current activity document
      DocumentSnapshot activitySnapshot =
          await _firestore.collection('activities').doc(activityId).get();

      if (!activitySnapshot.exists) {
        throw Exception("Activity not found");
      }

      // Update the activity details
      await _firestore.collection('activities').doc(activityId).update({
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
        'category': category,
        'maxVolunteers': maxVolunteers,
        'lastUpdateDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception("Failed to update activity: $e");
    }
  }

  // Delete an activity
  Future<void> deleteActivity(String activityId) async {
    try {
      // Delete the activity from Firestore
      await _firestore.collection('activities').doc(activityId).delete();
    } catch (e) {
      throw Exception("Failed to delete activity: $e");
    }
  }

// Get a list of activities filtered by title (search parameter)
  Future<List<Activity>> getActivities({
    String? titleSearch,
    String? category,
  }) async {
    try {
      Query query = _firestore.collection('activities');

      if (titleSearch != null && titleSearch.isNotEmpty) {
        // Split the search term into individual words and filter activities by title
        List<String> searchKeywords = titleSearch.split(' ').map((word) => word.toLowerCase()).toList();
        query = query.where('title', arrayContainsAny: searchKeywords);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      // Retrieve the activities matching the filters
      QuerySnapshot querySnapshot = await query.get();
      List<Activity> activities = querySnapshot.docs
          .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return activities;
    } catch (e) {
      throw Exception("Failed to fetch activities: $e");
    }
  }

  // Get details of a specific activity
  Future<Activity> getActivityDetails(String activityId) async {
    try {
      DocumentSnapshot activitySnapshot =
          await _firestore.collection('activities').doc(activityId).get();

      if (!activitySnapshot.exists) {
        throw Exception("Activity not found");
      }

      return Activity.fromMap(activitySnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Failed to fetch activity details: $e");
    }
  }

  Future<void> createMultipleActivities() async {
    try {
      // Verificar si ya existen actividades
      final activitySnapshot = await _firestore.collection('activities').where('title', isEqualTo: 'Taller de educación ambiental').get();
      if (activitySnapshot.docs.isNotEmpty) {
        print('Las actividades ya han sido creadas previamente.');
        return; // No crear actividades si ya hay registros
      }

      // Listado de localizaciones del Caribe colombiano
      List<String> locations = [
        'Cartagena, Bolívar',
        'Santa Marta, Magdalena',
        'Barranquilla, Atlántico',
        'San Andrés, Providencia y Santa Catalina',
        'Riohacha, La Guajira',
        'Montería, Córdoba',
        'Sincelejo, Sucre',
      ];

      // Categorías disponibles
      List<String> categories = [
        'Educación',
        'Salud',
        'Medio Ambiente',
      ];

      // Datos de ejemplo para las actividades
      List<Map<String, dynamic>> activityData = [
        {
          'title': 'Taller de educación ambiental',
          'description': 'Un taller para enseñar sobre el cuidado del medio ambiente.',
          'date': DateTime(2024, 5, 1, 9, 0), // Fecha ejemplo
          'location': locations[0], // Cartagena
          'category': categories[2], // Medio Ambiente
          'maxVolunteers': 30,
        },
        {
          'title': 'Campaña de vacunación',
          'description': 'Campaña para promover la vacunación en comunidades vulnerables.',
          'date': DateTime(2024, 6, 15, 8, 0), // Fecha ejemplo
          'location': locations[1], // Santa Marta
          'category': categories[1], // Salud
          'maxVolunteers': 50,
        },
        {
          'title': 'Clases de refuerzo para niños',
          'description': 'Clases de matemáticas y lenguaje para niños en situación de vulnerabilidad.',
          'date': DateTime(2024, 7, 10, 10, 0), // Fecha ejemplo
          'location': locations[2], // Barranquilla
          'category': categories[0], // Educación
          'maxVolunteers': 20,
        },
        {
          'title': 'Limpieza de playas',
          'description': 'Actividad de limpieza de playas para promover la conservación del entorno.',
          'date': DateTime(2024, 8, 5, 7, 30), // Fecha ejemplo
          'location': locations[3], // San Andrés
          'category': categories[2], // Medio Ambiente
          'maxVolunteers': 25,
        },
        {
          'title': 'Programa de salud comunitaria',
          'description': 'Programa para atención médica gratuita en comunidades rurales.',
          'date': DateTime(2024, 9, 20, 8, 0), // Fecha ejemplo
          'location': locations[4], // Riohacha
          'category': categories[1], // Salud
          'maxVolunteers': 40,
        },
        {
          'title': 'Educación para todos',
          'description': 'Programa de alfabetización para adultos mayores.',
          'date': DateTime(2024, 10, 12, 14, 0), // Fecha ejemplo
          'location': locations[5], // Montería
          'category': categories[0], // Educación
          'maxVolunteers': 15,
        },
        {
          'title': 'Conservación de la fauna marina',
          'description': 'Iniciativa para la protección de especies marinas en peligro de extinción.',
          'date': DateTime(2024, 11, 3, 16, 0), // Fecha ejemplo
          'location': locations[6], // Sincelejo
          'category': categories[2], // Medio Ambiente
          'maxVolunteers': 35,
        },
      ];

      // Crear las actividades en Firestore
      for (var data in activityData) {
        String activityId = _firestore.collection('activities').doc().id; // Nuevo ID
        Activity newActivity = Activity(
          id: activityId,
          title: data['title'],
          description: data['description'],
          date: data['date'],
          location: data['location'],
          category: data['category'],
          maxVolunteers: data['maxVolunteers'],
          status: ActivityStatus.active, // Estado siempre 'active'
          creatorId: 'system', // Asignar un creador por defecto
          creationDate: DateTime.now(),
          lastUpdateDate: DateTime.now(),
        );

        await _firestore
            .collection('activities')
            .doc(activityId)
            .set(newActivity.toMap());

        print('Actividad creada: ${data['title']}');
      }
    } catch (e) {
      print('Error creando las actividades: $e');
    }
  }
}
