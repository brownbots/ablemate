import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RequestTaskScreen extends StatefulWidget {
  const RequestTaskScreen({super.key});

  @override
  State<RequestTaskScreen> createState() => _RequestTaskScreenState();
}

class _RequestTaskScreenState extends State<RequestTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> taskTypes = [
    'Grocery Shopping',
    'House Cleaning',
    'Companionship',
    'Transportation',
    'Meal Preparation',
    'Medication Reminders',
    'Helping with Exercises',
    'Monitoring Health Conditions',
    'Assisting with Doctor Visits',
    'Medical',
    'Check-in',
  ];

  final List<String> priorities = ['Low', 'Medium', 'High'];

  String? selectedTaskType;
  String? selectedPriority;
  bool isSubmitting = false;
  String? authToken;
  bool isAuthenticated = false;

  final TextEditingController shortDescController = TextEditingController();
  final TextEditingController detailedDescController = TextEditingController();

  static const String baseUrl = 'http://192.168.1.6:8000';

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      authToken = token;
      isAuthenticated = token != null && token.isNotEmpty;
    });
    print('Auth token loaded: ${token != null ? "Yes" : "No"}');
  }

  Future<void> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Backend connection successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    final endpoint = isAuthenticated ? '/api/tasks/authenticated' : '/api/tasks/';
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (isAuthenticated && authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final requestBody = {
        'title': shortDescController.text.trim(),
        'description': detailedDescController.text.trim(),
        'priority': selectedPriority!.toLowerCase(),
        'task_type': selectedTaskType,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Task request submitted successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );

        shortDescController.clear();
        detailedDescController.clear();
        setState(() {
          selectedTaskType = null;
          selectedPriority = null;
        });
      } else {
        String errorMessage = 'Submission failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            if (errorData['detail'] is List) {
              errorMessage = (errorData['detail'] as List)
                  .map((e) => e['msg'] ?? e.toString())
                  .join(', ');
            } else {
              errorMessage = errorData['detail'].toString();
            }
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      String errorMessage = e.toString().contains('TimeoutException')
          ? 'Request timed out. Is the backend running?'
          : 'Connection error. Check your network or IP.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    shortDescController.dispose();
    detailedDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request a Task"),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            onPressed: testConnection,
            tooltip: 'Test Backend Connection',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection Info
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Backend URL: $baseUrl', style: const TextStyle(fontSize: 12)),
                            Text('Auth Status: ${isAuthenticated ? "Logged in" : "Anonymous"}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isAuthenticated)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_outlined, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You are not logged in. Tasks will be submitted anonymously.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                DropdownButtonFormField<String>(
                  value: selectedTaskType,
                  items: taskTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: isSubmitting ? null : (val) => setState(() => selectedTaskType = val),
                  decoration: const InputDecoration(
                    labelText: 'Task Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (value) => value == null ? 'Please select a task type' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: shortDescController,
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(
                    labelText: 'Short Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.short_text),
                    hintText: 'Brief summary of the task',
                  ),
                  maxLength: 100,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Short description is required';
                    } else if (value.trim().length < 5) {
                      return 'Must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: detailedDescController,
                  enabled: !isSubmitting,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'Explain what help you need',
                    alignLabelWithHint: true,
                  ),
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Detailed description is required';
                    } else if (value.trim().length < 10) {
                      return 'Must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  items: priorities.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: {
                                'High': Colors.red,
                                'Medium': Colors.orange,
                                'Low': Colors.green,
                              }[e],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(e),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: isSubmitting ? null : (val) => setState(() => selectedPriority = val),
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.priority_high),
                  ),
                  validator: (value) => value == null ? 'Please select a priority' : null,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text("Submitting..."),
                      ],
                    )
                        : const Text(
                      "Submit Request",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your task request will be reviewed and matched with available volunteers.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
