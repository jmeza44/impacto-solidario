import 'package:flutter/material.dart';
import 'package:impacto_solidario/main.dart';
import 'package:impacto_solidario/models/user.dart';
import 'package:impacto_solidario/views/volunteer_dashboard_view.dart';
import '../services/authentication_service.dart';
import 'admin_dashboard_view.dart';

class MainDashboardView extends StatefulWidget {
  const MainDashboardView({super.key});

  @override
  _MainDashboardViewState createState() => _MainDashboardViewState();
}

class _MainDashboardViewState extends State<MainDashboardView> {
  late String userRole = UserRole.volunteer.name;
  late String firstName = '';
  late String lastName = '';
  late String userEmail = '';
  bool isLoading = true;

  final AuthenticationService _authenticationService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndInfo();
  }

  void _loadUserRoleAndInfo() async {
    try {
      String role = await _authenticationService.getUserRole();
      var userProfile = await _authenticationService
          .getUserProfile(await _authenticationService.getCurrentUserId());

      setState(() {
        userRole = role;
        firstName = userProfile['firstName'];
        lastName = userProfile['lastName'];
        userEmail = userProfile['email'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _authenticationService.signOut();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
      drawer: _buildSidebar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userRole == UserRole.administrator.name
              ? const AdminDashboardView() // For Administrators
              : const VolunteerDashboardView(), // For Volunteers
    );
  }

  // Build Sidebar Menu based on user role
  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('$firstName $lastName'), // Dynamic user name
            accountEmail: Text(userEmail), // Dynamic user email
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blueAccent.shade100,
              child: Text(
                '${(firstName == '' ? 'User' : firstName)[0]}${(lastName == '' ? 'User' : lastName)[0]}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ),
          ListTile(
            title: const Text('Inicio'),
            leading: const Icon(Icons.dashboard),
            onTap: () {
              Navigator.pushReplacementNamed(context, Routes.mainDashboard);
            },
          ),
          if (userRole == UserRole.administrator.name) ...[
            ListTile(
              title: const Text('Estadísticas Globales'),
              leading: const Icon(Icons.bar_chart),
              onTap: () {
                Navigator.pushNamed(context, Routes.globalStatistics);
              },
            ),
            ListTile(
              title: const Text('Lista de Actividades'),
              leading: const Icon(Icons.list),
              onTap: () {
                Navigator.pushNamed(context, Routes.activityList);
              },
            ),
            ListTile(
              title: const Text('Registro de Asistencia'),
              leading: const Icon(Icons.assignment),
              onTap: () {
                Navigator.pushNamed(context, Routes.attendanceRegister);
              },
            ),
          ] else ...[
            ListTile(
              title: const Text('Mi Perfil'),
              leading: const Icon(Icons.account_circle),
              onTap: () {
                Navigator.pushNamed(context, Routes.userProfile);
              },
            ),
            ListTile(
              title: const Text('Mis Actividades'),
              leading: const Icon(Icons.event),
              onTap: () {
                Navigator.pushNamed(context, Routes.activityList);
              },
            ),
            ListTile(
              title: const Text('Mis Estadísticas'),
              leading: const Icon(Icons.stacked_bar_chart),
              onTap: () {
                Navigator.pushNamed(context, Routes.globalStatistics);
              },
            ),
          ],
        ],
      ),
    );
  }
}
