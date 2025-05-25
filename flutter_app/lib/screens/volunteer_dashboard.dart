import 'package:flutter/material.dart';

class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({super.key});

  Widget taskCard(String title, String subtitle, String priority) {
    Color color = {
      'High': Colors.red,
      'Medium': Colors.orange,
      'Low': Colors.green,
    }[priority]!;

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(priority, style: TextStyle(color: color)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volunteer Dashboard 💙")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          taskCard("Grocery Pickup", "Pick up groceries for Ms. Jane", "Medium"),
          taskCard("Medical Appointment", "Transport Mr. Kumar to hospital", "High"),
          taskCard("Friendly Check-in", "Call in to check in", "Low"),
        ],
      ),
    );
  }
}
