import 'package:flutter/material.dart';
import 'package:ablemate/screens/request_task.dart';
import 'package:ablemate/screens/volunteer_dashboard.dart';
import 'package:ablemate/screens/success_stories.dart';
import 'package:ablemate/screens/profile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome 💙',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _DashboardCard(
                    title: 'Request Task',
                    subtitle:
                    'Need a helping hand?\nSubmit a request and get matched with a trusted volunteer.',
                    icon: Icons.person_add_alt_1,
                    color: Colors.blue.shade100,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RequestTaskScreen()),
                    ),
                  ),
                  _DashboardCard(
                    title: 'Volunteer Dashboard',
                    subtitle:
                    'Support where it matters.\nView, accept, and manage tasks from people in your community.',
                    icon: Icons.edit_note,
                    color: Colors.pink.shade100,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const VolunteerDashboardScreen()),
                    ),
                  ),
                  _DashboardCard(
                    title: 'Stories',
                    subtitle:
                    'Inspire and be inspired.\nRead heartwarming stories from volunteers and recipients alike.',
                    icon: Icons.article,
                    color: Colors.grey.shade300,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const SuccessStoriesScreen()),
                    ),
                  ),
                  _DashboardCard(
                    title: 'Profile',
                    subtitle:
                    'Manage your journey.\nUpdate personal details, availability, and preferences.',
                    icon: Icons.account_circle,
                    color: Colors.orange.shade100,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // Implement navigation if needed
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 24,
                  child: Icon(icon, size: 28, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
