import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestion_de_taches/database/database_helper.dart';
import 'package:gestion_de_taches/widgets/task_item.dart';
import 'package:gestion_de_taches/screens/add_task_screen.dart';
import 'package:gestion_de_taches/screens/edit_task_screen.dart';

class TAskListScreen extends StatefulWidget {
  const TAskListScreen({super.key});

  @override
  createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TAskListScreen> {
  List<Map<String, dynamic>> tasks = [];
  Map<String, bool> filters = {
    'Todo': true,
    'In progress': true,
    'Done': true,
    'Bug': true,
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final dbTasks = await DatabaseHelper().getTasks();
    setState(() {
      tasks = dbTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Todo App',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt,
                color: Colors.white), // Changed filter icon
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => TaskItem(
                  initialFilters: filters,
                  onFilterChanged: (newFilters) {
                    setState(() {
                      filters = newFilters;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _buildTaskList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          if (result == true) {
            _loadTasks();
          }
        },
        backgroundColor: Colors.black, // Changed to black
        child: const Icon(Icons.add, color: Colors.white), // White plus icon
      ),
    );
  }

  Widget _buildTaskList() {
  if (tasks.isEmpty) {
    return const Center(child: Text("Vous n'avez aucune tâche!"));
  }
  return ListView.builder(
    itemCount: _filteredTasks().length,
    itemBuilder: (context, index) {
      final task = _filteredTasks()[index];
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: _getStatusColor(task['status'])),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          leading: Icon(Icons.circle, color: _getStatusColor(task['status'])),
          title: Text(
            task['title'],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold, // Make the title bold
            ),
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                  task: {
                    'id': task['id'].toString(),
                    'title': task['title'],
                    'description': task['description'],
                    'status': task['status'],
                  },
                  onUpdate: (updatedTask) {
                    setState(() {
                      tasks = List.from(tasks)
                        ..removeAt(index)
                        ..insert(index, updatedTask);
                    });
                  },
                ),
              ),
            );
            // Use the 'result' variable here if needed
            if (kDebugMode) {
              print('Result from Navigator: $result');
            }
          },
        ),
      );
    },
  );
}


  List<Map<String, dynamic>> _filteredTasks() {
    return tasks.where((task) {
      return filters[task['status']]!;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In progress':
        return Colors.blue;
      case 'Done':
        return Colors.green;
      case 'Bug':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
