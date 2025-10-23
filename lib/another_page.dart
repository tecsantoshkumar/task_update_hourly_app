import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnotherPage extends StatefulWidget {
  const AnotherPage({super.key});

  @override
  State<AnotherPage> createState() => _AnotherPageState();
}

class _AnotherPageState extends State<AnotherPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedProjectId; // we'll store project_id, not just name
  String task = '', doing = '', issue = '', nextPlan = '';

  List<Map<String, dynamic>> projects = []; // store full project info

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  /// 🔹 Fetch list of projects from backend
  Future<void> fetchProjects() async {
    final url =
        Uri.parse('https://electrotechsolution.com/api/list_projects.php');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['projects'] != null) {
          setState(() {
            projects = List<Map<String, dynamic>>.from(data['projects']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No projects found')),
          );
        }
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading projects: $e')),
      );
    }
  }

  /// 🔹 Send task data to the PHP backend
  Future<void> addTask() async 
  {
    final url =
        Uri.parse('https://electrotechsolution.com/api/add_task.php'); // your API

    final selectedProject = projects.firstWhere(
      (p) => p['project_id'].toString() == selectedProjectId,
      orElse: () => {},
    );

    final payload = {
      'project_id': selectedProjectId,
      'project_name': selectedProject['project_name'] ?? '',
      'task': task,
      'what_are_doing': doing,
      'issue_faced': issue,
      'next_hour_plan': nextPlan,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final resData = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resData['message'] ?? 'Unknown response')),
      );

      if (resData['status'] == 'success') {
        _formKey.currentState?.reset();
        setState(() => selectedProjectId = null);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedProjectId,
                hint: const Text('Select Project'),
                items: projects.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['project_id'].toString(),
                    child: Text('${p['project_name']} (${p['project_status']})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedProjectId = val),
                validator: (val) =>
                    val == null ? 'Please select a project' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Task'),
                onChanged: (val) => task = val,
                validator: (val) => val!.isEmpty ? 'Enter task' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'What are you doing'),
                onChanged: (val) => doing = val,
                validator: (val) => val!.isEmpty ? 'Enter details' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Issue faced'),
                onChanged: (val) => issue = val,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Next hour plan'),
                onChanged: (val) => nextPlan = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                label: const Text('Add Task'),
                onPressed: () 
                {
                  if (_formKey.currentState!.validate()) 
                  {
                    addTask();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
