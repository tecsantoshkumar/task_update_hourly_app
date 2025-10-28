import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<dynamic> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://electrotechsolution.com/api/get_tasks.php'),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _tasks = data['tasks'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'No tasks found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching tasks: $e';
        _isLoading = false;
      });
    }
  }

  /// 🖨 Generate and preview PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text("Task Report",
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: [
              'Project',
              'Task',
              'Doing',
              'Issue',
              'Next Plan',
              'Updated At'
            ],
            data: _tasks.map((task) {
              return [
                task['project_name'] ?? '',
                task['task'] ?? '',
                task['what_are_doing'] ?? '',
                task['issue_faced'] ?? '',
                task['next_hour_plan'] ?? '',
                task['updated_at'] ?? '',
              ];
            }).toList(),
          )
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
            onPressed: _tasks.isEmpty ? null : _generatePdf,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/taskupdate');
        },
        label: const Text("Add Task"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: fetchTasks,
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task['project_name'] ?? 'Unknown Project',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Task: ${task['task'] ?? ''}',
                                  style: const TextStyle(fontSize: 15)),
                              Text('Doing: ${task['what_are_doing'] ?? ''}',
                                  style: const TextStyle(fontSize: 15)),
                              Text('Issue: ${task['issue_faced'] ?? ''}',
                                  style: const TextStyle(fontSize: 15)),
                              Text('Next Plan: ${task['next_hour_plan'] ?? ''}',
                                  style: const TextStyle(fontSize: 15)),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  'Updated: ${task['updated_at'] ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
