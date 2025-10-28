import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaskUpdate extends StatefulWidget {
  const TaskUpdate({super.key});

  @override
  State<TaskUpdate> createState() => _TaskUpdateState();
}

class _TaskUpdateState extends State<TaskUpdate> {
  final _formKey = GlobalKey<FormState>();

  String? selectedProjectId;
  String task = '', doing = '', issue = '', nextPlan = '';

  List<Map<String, dynamic>> projects = [];

  bool isLoading = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    setState(() => isLoading = true);
    final url = Uri.parse('https://electrotechsolution.com/api/list_projects.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['projects'] != null) {
          setState(() {
            projects = List<Map<String, dynamic>>.from(data['projects']);
          });
        } else {
          _showSnack('No projects found');
        }
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      _showSnack('Error loading projects: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addTask() async {
    setState(() => isSubmitting = true);
    final url = Uri.parse('https://electrotechsolution.com/api/add_task.php');

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
      _showSnack(resData['message'] ?? 'Unknown response');

      if (resData['status'] == 'success') {
        _formKey.currentState?.reset();
        setState(() => selectedProjectId = null);
      }
    } catch (e) {
      _showSnack('Error adding task: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Update"),
        elevation: 4,
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.zero,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedProjectId,
                            decoration: const InputDecoration(
                              labelText: 'Select Project',
                              prefixIcon: Icon(Icons.work_outline),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            items: projects.map((p) {
                              return DropdownMenuItem<String>(
                                value: p['project_id'].toString(),
                                child: Text(
                                    '${p['project_name']} (${p['project_status']})'),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => selectedProjectId = val),
                            validator: (val) =>
                                val == null ? 'Please select a project' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Task',
                            icon: Icons.task_alt_outlined,
                            onChanged: (val) => task = val,
                            validator: (val) =>
                                val!.isEmpty ? 'Enter task' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'What are you doing',
                            icon: Icons.engineering_outlined,
                            onChanged: (val) => doing = val,
                            validator: (val) =>
                                val!.isEmpty ? 'Enter details' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Issue faced',
                            icon: Icons.warning_amber_outlined,
                            onChanged: (val) => issue = val,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Next hour plan',
                            icon: Icons.schedule_outlined,
                            onChanged: (val) => nextPlan = val,
                          ),
                          const SizedBox(height: 30),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isSubmitting
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.save_alt),
                                    label: const Text(
                                      'Task update',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        addTask();
                                      }
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
