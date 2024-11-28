import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { administrator, volunteer }

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final UserRole role;
  final DateTime registrationDate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.registrationDate,
  });

  // Convert User object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role.name, // Store enum as string
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  // Create User object from Firestore map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      registrationDate: (map['registrationDate'] as Timestamp).toDate(),
    );
  }
}
