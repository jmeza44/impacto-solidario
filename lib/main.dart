import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:impacto_solidario/firebase_options.dart';
import 'package:impacto_solidario/models/user.dart' as app_user;
import 'package:impacto_solidario/services/authentication_service.dart';
import 'package:impacto_solidario/services/shared_preferences_service.dart';
import 'package:impacto_solidario/views/access_denied_view.dart';
import 'package:impacto_solidario/views/activity_list_view.dart';
import 'package:impacto_solidario/views/admin_dashboard_view.dart';
import 'package:impacto_solidario/views/attendance_register_view.dart';
import 'package:impacto_solidario/views/create_edit_activity_view.dart';
import 'package:impacto_solidario/views/feedback_view.dart';
import 'package:impacto_solidario/views/global_statistics_view.dart';
import 'package:impacto_solidario/views/login_view.dart';
import 'package:impacto_solidario/views/main_dashboard_view.dart';
import 'package:impacto_solidario/views/register_view.dart';
import 'package:impacto_solidario/views/user_profile_view.dart';
import 'package:impacto_solidario/views/volunteer_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voluntariado App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthenticationWrapper(),
      routes: {
        Routes.login: (context) => const LoginView(),
        Routes.register: (context) => const RegisterView(),
        Routes.activityList: (context) => const ActivityListView(),
        Routes.createEditActivity: (context) => RouteGuard(
              adminView: const CreateEditActivityView(),
              volunteerView: const MainDashboardView(),
            ),
        Routes.attendanceRegister: (context) => RouteGuard(
              adminView: const AttendanceRegisterView(
                activityId: '',
              ),
              volunteerView: const MainDashboardView(),
            ),
        Routes.userProfile: (context) => const UserProfileView(),
        Routes.feedback: (context) => const FeedbackView(
              activityId: '',
            ),
        Routes.globalStatistics: (context) => const GlobalStatisticsView(),
        Routes.mainDashboard: (context) => const MainDashboardView(),
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final AuthenticationService _authenticationService = AuthenticationService();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            _clearSession(); // Clear session on unauthentication
            return const LoginView();
          } else {
            return FutureBuilder<void>(
              future: _ensureSessionIsSet(user.uid),
              builder: (context, sessionSnapshot) {
                if (sessionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (sessionSnapshot.hasError) {
                  return const Center(
                      child: Text("Error setting user session"));
                } else {
                  return FutureBuilder<Map<String, String>>(
                    future: _sharedPreferencesService.getUserSession(),
                    builder: (context, roleSnapshot) {
                      if (roleSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (roleSnapshot.hasError ||
                          !roleSnapshot.hasData) {
                        return const Center(
                            child: Text("Error loading user session"));
                      } else {
                        return const MainDashboardView();
                      }
                    },
                  );
                }
              },
            );
          }
        }

        return const Center(
            child: CircularProgressIndicator()); // Loading indicator
      },
    );
  }

  Future<void> _ensureSessionIsSet(String userId) async {
    var role = await _authenticationService.getUserRole();
    await _sharedPreferencesService.setUserSession(userId, role);
  }

  Future<void> _clearSession() async {
    await _sharedPreferencesService.clearUserSession();
  }
}

class RouteGuard extends StatelessWidget {
  final Widget adminView;
  final Widget volunteerView;
  final AuthenticationService authService = AuthenticationService();

  RouteGuard({
    super.key,
    required this.adminView,
    required this.volunteerView,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: authService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          String role = snapshot.data!;
          if (role == app_user.UserRole.administrator.name) {
            return adminView;
          } else if (role == app_user.UserRole.volunteer.name) {
            return volunteerView;
          } else {
            return const AccessDeniedView(); // Dedicated screen for access denial
          }
        } else {
          return const Center(child: Text("Unexpected error"));
        }
      },
    );
  }
}

// Define your routes
class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String activityList = '/activities';
  static const String createEditActivity = '/createEditActivity';
  static const String attendanceRegister = '/attendanceRegister';
  static const String userProfile = '/profile';
  static const String feedback = '/feedback';
  static const String globalStatistics = '/statistics';
  static const String mainDashboard = '/dashboard';
}
