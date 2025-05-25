import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? fullName;
  String? email;
  String? dateOfBirth;
  String? gender;
  String? disabilityStatus;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        fullName = prefs.getString('user_fullname');
        email = prefs.getString('user_email');
        dateOfBirth = prefs.getString('user_dob');
        gender = prefs.getString('user_gender');
        disabilityStatus = prefs.getString('user_disability');
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored user data
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  Future<void> _navigateToEditProfile() async {
    // Wait for the edit profile screen to return
    final result = await Navigator.pushNamed(
      context,
      '/edit_profile',
      arguments: {
        'fullName': fullName,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'disabilityStatus': disabilityStatus,
      },
    );

    // If the edit was successful, reload the data
    if (result == true) {
      await _loadUserData();
    }
  }

  String _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return 'N/A';
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return '$age years old';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Not provided';
    try {
      final parsedDate = DateTime.parse(date);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  Color _getAvatarColor() {
    if (disabilityStatus == null || disabilityStatus == 'None') {
      return Colors.blue;
    }
    switch (disabilityStatus) {
      case 'Physical':
        return Colors.green;
      case 'Visual':
        return Colors.orange;
      case 'Hearing':
        return Colors.purple;
      case 'Cognitive':
        return Colors.teal;
      case 'Speech':
        return Colors.indigo;
      case 'Mental Health':
        return Colors.pink;
      case 'Multiple':
        return Colors.red;
      case 'Senior Citizen':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  String _getInitials() {
    if (fullName == null || fullName!.isEmpty) return 'U';
    final names = fullName!.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _getAvatarColor(),
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    fullName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _calculateAge(dateOfBirth),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile Details
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: email ?? 'Not provided',
                    color: Colors.red,
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.cake_outlined,
                    title: "Date of Birth",
                    subtitle: _formatDate(dateOfBirth),
                    color: Colors.pink,
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: gender == 'Male'
                        ? Icons.male
                        : gender == 'Female'
                        ? Icons.female
                        : Icons.person_outline,
                    title: "Gender",
                    subtitle: gender ?? 'Not specified',
                    color: Colors.blue,
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.accessibility_new,
                    title: "Accessibility Status",
                    subtitle: disabilityStatus ?? 'Not specified',
                    color: _getAvatarColor(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Actions
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.indigo),
                    title: const Text("Edit Profile"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _navigateToEditProfile,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.grey),
                    title: const Text("Settings"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings feature coming soon!')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout", style: TextStyle(color: Colors.red)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await _logout();
                              },
                              child: const Text("Logout", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }
}