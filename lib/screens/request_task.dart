import 'package:flutter/material.dart';

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

  final TextEditingController shortDescController = TextEditingController();
  final TextEditingController detailedDescController = TextEditingController();

  final List<String> priorities = ['Low', 'Medium', 'High'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request a Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedTaskType,
                items: taskTypes
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() {
                  selectedTaskType = val;
                }),
                decoration: const InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: shortDescController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: detailedDescController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                items: priorities
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() {
                  selectedPriority = val;
                }),
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle submission logic here
                    if (selectedTaskType != null &&
                        selectedPriority != null &&
                        shortDescController.text.isNotEmpty &&
                        detailedDescController.text.isNotEmpty) {
                      // Example: show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Task request submitted')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill in all fields')),
                      );
                    }
                  },
                  child: const Text("Submit Request"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
