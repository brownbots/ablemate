import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            CircleAvatar(radius: 40, backgroundColor: Colors.blue),
            SizedBox(height: 10),
            Text("Arjun Mehta", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Volunteer – Delhi"),
            Divider(height: 30),
            ListTile(title: Text("📍 Location"), subtitle: Text("Delhi, India")),
            ListTile(title: Text("📧 Email"), subtitle: Text("arjun.mehta@example.com")),
            ListTile(title: Text("📞 Contact"), subtitle: Text("+91 98765 43210")),
            ListTile(title: Text("📝 About Me"), subtitle: Text("I enjoy helping others...")),
          ],
        ),
      ),
    );
  }
}
