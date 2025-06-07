import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestTaskScreen extends StatefulWidget {
  const RequestTaskScreen({super.key});

  @override
  State<RequestTaskScreen> createState() => _RequestTaskScreenState();
}

class _RequestTaskScreenState extends State<RequestTaskScreen> {
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

  String? selectedTaskType;
  String? selectedPriority;
  bool isSubmitting = false;

  final TextEditingController shortDescController = TextEditingController();
  final TextEditingController detailedDescController = TextEditingController();

  final List<String> priorities = ['Low', 'Medium', 'High'];

  Future<void> submitTask() async {
    setState(() {
      isSubmitting = true;
    });

    final url = Uri.parse('http://192.168.1.18:8000/tasks/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': shortDescController.text.trim(),
          'description': detailedDescController.text.trim(),
          'priority': selectedPriority,
          'task_type': selectedTaskType,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task request submitted successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form after successful submission
        shortDescController.clear();
        detailedDescController.clear();
        setState(() {
          selectedTaskType = null;
          selectedPriority = null;
        });

        // Optional: Navigate back or to another screen
        // Navigator.pop(context);

      } else {
        // Parse error message if available
        String errorMessage = 'Submission failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          }
        } catch (e) {
          errorMessage = 'Submission failed with status: ${response.statusCode}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Request failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error occurred. Please check your connection.'),
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
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Type Dropdown
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a task type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Short Description Field
              TextField(
                controller: shortDescController,
                enabled: !isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.short_text),
                  hintText: 'Brief summary of the task',
                ),
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Detailed Description Field
              TextField(
                controller: detailedDescController,
                enabled: !isSubmitting,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Provide detailed information about what help you need',
                  alignLabelWithHint: true,
                ),
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Priority Dropdown
              DropdownButtonFormField<String>(
                value: selectedPriority,
                items: priorities
                    .map((e) => DropdownMenuItem(
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
                ))
                    .toList(),
                onChanged: isSubmitting ? null : (val) => setState(() => selectedPriority = val),
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () {
                    // Validate all fields
                    if (shortDescController.text.trim().isEmpty ||
                        detailedDescController.text.trim().isEmpty ||
                        selectedPriority == null ||
                        selectedTaskType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Additional validation
                    if (shortDescController.text.trim().length < 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Short description must be at least 5 characters'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (detailedDescController.text.trim().length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Detailed description must be at least 10 characters'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    submitTask();
                  },
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

              // Help Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your task request will be reviewed and matched with available volunteers.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}