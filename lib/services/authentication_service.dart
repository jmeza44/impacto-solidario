import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:impacto_solidario/models/user.dart';
import 'package:impacto_solidario/services/shared_preferences_service.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

// Sign Up
  Future<String> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Create a new user with Firebase Authentication
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful registration, save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phoneNumber,
        'role': UserRole.volunteer.name, // Default role for new users
        'registrationDate': DateTime.now().toIso8601String(),
      });

      // Save user role in SharedPreferences
      await _sharedPreferencesService.setUserSession(
          userCredential.user!.uid, UserRole.volunteer.name);

      return userCredential.user!.uid;
    } on FirebaseAuthException {
      rethrow;
    }
  }

// Sign In
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in using Firebase Authentication
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Update User Profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    var user = _firebaseAuth.currentUser;

    if (user != null) {
      // Update the user's profile in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phoneNumber,
      });
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  // Get Current User ID
  Future<String> getCurrentUserId() async {
    var user = _firebaseAuth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        var mappedData = userDoc.data() as Map<String, dynamic>;
        mappedData['id'] = userId;
        return mappedData;
      } else {
        throw Exception("User profile not found.");
      }
    } catch (e) {
      throw Exception("Failed to fetch user profile: $e");
    }
  }

  // Get User Role
  Future<String> getUserRole() async {
    var user = _firebaseAuth.currentUser;
    if (user == null) return '';

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc['role'] as String; // Assuming role is stored as a string
      } else {
        throw Exception("User data not found.");
      }
    } catch (e) {
      throw Exception("Failed to fetch user role: $e");
    }
  }
}
