import 'package:flutter/material.dart';
import 'screens/get_started.dart';
import 'screens/register.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/request_task.dart';
import 'screens/volunteer_dashboard.dart';
import 'screens/success_stories.dart';
import 'screens/profile.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/get-started': (context) => const GetStartedScreen(),
  '/register': (context) => const RegisterScreen(),
  '/login': (context) => const LoginScreen(),
  '/dashboard': (context) => const DashboardScreen(),
  '/request-task': (context) => const RequestTaskScreen(),
  '/volunteer': (context) => const VolunteerDashboardScreen(),
  '/stories': (context) => const SuccessStoriesScreen(),
  '/profile': (context) => const ProfileScreen(),
};
