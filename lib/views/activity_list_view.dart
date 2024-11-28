import 'package:flutter/material.dart';
import 'package:impacto_solidario/main.dart';
import 'package:impacto_solidario/models/user.dart';
import '../services/activity_service.dart';
import '../services/shared_preferences_service.dart';
import '../models/activity.dart';
import '../widgets/activity_card.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/search_and_filters.dart';

class ActivityListView extends StatefulWidget {
  const ActivityListView({super.key});

  @override
  _ActivityListViewState createState() => _ActivityListViewState();
}

class _ActivityListViewState extends State<ActivityListView> {
  final ActivityService _activityService = ActivityService();
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  List<Activity> _activities = [];
  String _userRole = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _loadUserRole();
  }

  Future<void> _loadActivities() async {
    try {
      List<Activity> activities = await _activityService.getActivities(
        titleSearch: null,
        category: _selectedCategory,
      );
      setState(() {
        _activities = activities;
      });
    } catch (e) {
      _showError("Failed to load activities: $e");
    }
  }

  Future<void> _loadUserRole() async {
    try {
      Map<String, String> session = await _prefsService.getUserSession();
      setState(() {
        _userRole = session['role'] ?? '';
      });
    } catch (e) {
      _showError("Failed to load user role: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity List"),
      ),
      body: Column(
        children: [
          SearchAndFilters(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
              _loadActivities();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                Activity activity = _activities[index];
                return ActivityCard(activity: activity);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _userRole == UserRole.administrator.name
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.createEditActivity);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
