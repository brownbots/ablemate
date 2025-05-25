import 'package:flutter/material.dart';

class SuccessStoriesScreen extends StatelessWidget {
  const SuccessStoriesScreen({super.key});

  Widget storyCard(String name, String location, String story) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location),
            const SizedBox(height: 8),
            Text(story),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Success Stories ✨")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          storyCard("Arjun Mehta", "Volunteer – Delhi", "Helping Mr. Sharma with groceries weekly."),
          storyCard("Anika Sinha", "Volunteer – Mumbai", "Connected emotionally with elderly."),
          storyCard("Rahul Dev", "Volunteer – Delhi", "Found purpose through volunteering."),
        ],
      ),
    );
  }
}
