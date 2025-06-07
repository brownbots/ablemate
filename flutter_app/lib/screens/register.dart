import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? selectedGender;
  String? selectedDisability;
  String? selectedExperience;
  String? errorMessage;
  String role = 'volunteer'; // default fallback

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && (args == 'volunteer' || args == 'dependent')) {
      setState(() => role = args as String);
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_fullname', nameController.text.trim());
    await prefs.setString('user_email', emailController.text.trim());
    await prefs.setString('user_dob', dobController.text.trim());
    await prefs.setString('user_gender', selectedGender ?? '');
    if (role == 'dependent') {
      await prefs.setString('user_disability', selectedDisability ?? '');
    } else {
      await prefs.setString('user_experience', selectedExperience ?? '');
    }
  }

  Future<void> registerUser() async {
    final fullName = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final dob = dobController.text.trim();

    // Basic client-side validation
    if ([fullName, email, password, confirmPassword, dob].any((e) => e.isEmpty) ||
        selectedGender == null ||
        (role == 'dependent' && selectedDisability == null) ||
        (role == 'volunteer' && selectedExperience == null)) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      final url = Uri.parse('http://192.168.1.6:8000/api/auth/register');

      // Construct the request body dynamically based on the role
      final Map<String, dynamic> requestBody = {
        'full_name': fullName,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword, // FastAPI expects this for the validator
        'dob': dob,
        'gender': selectedGender!,
        'role': role,
      };

      // Conditionally add disability_status or experience
      if (role == 'dependent') {
        requestBody['disability_status'] = selectedDisability!;
      } else if (role == 'volunteer') {
        requestBody['experience'] = selectedExperience!;
      }

      // Encode the request body to JSON
      final jsonPayload = jsonEncode(requestBody);

      // Print the JSON payload to the console for debugging
      print('Sending JSON Payload: $jsonPayload');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonPayload, // Use the encoded JSON payload
      );

      // Handle the response based on status code
      if (response.statusCode == 201) { // Changed to 201 as per auth.py
        await _saveUserData();

        // Navigate to Dashboard on successful registration
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
        );
      } else {
        // Parse and display error message from the backend
        final responseBody = jsonDecode(response.body);
        setState(() {
          // FastAPI 422 errors have 'detail' which is a list of errors
          // For other errors, it might be a simple string
          if (responseBody.containsKey('detail') && responseBody['detail'] is List) {
            errorMessage = (responseBody['detail'] as List)
                .map((e) => e['msg'] ?? e.toString())
                .join('\n');
          } else {
            errorMessage = responseBody['detail'] ?? responseBody['message'] ?? 'Registration failed';
          }
        });
        print('Backend Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Catch and display any network or other errors
      setState(() {
        errorMessage = 'Error connecting to server: $e';
      });
      print('Flutter Error: $e');
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Register as ${role == 'volunteer' ? 'Volunteer' : 'Dependent'}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: const Text("Log in",
                            style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        // Ensure date format matches YYYY-MM-DD
                        dobController.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    items: ['Male', 'Female', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedGender = val),
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (role == 'dependent')
                    DropdownButtonFormField<String>(
                      value: selectedDisability,
                      items: [
                        'None',
                        'Physical',
                        'Visual',
                        'Hearing',
                        'Cognitive',
                        'Speech',
                        'Mental Health',
                        'Multiple',
                        'Senior Citizen'
                      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => selectedDisability = val),
                      decoration: const InputDecoration(
                        labelText: 'Disability Status',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  if (role == 'volunteer')
                    DropdownButtonFormField<String>(
                      value: selectedExperience,
                      items: [
                        '3 months',
                        '6 months',
                        '1 year',
                        '2 years',
                        'More than 2 years',
                      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => selectedExperience = val),
                      decoration: const InputDecoration(
                        labelText: 'Previous Experience',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Register', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
