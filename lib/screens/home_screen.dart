import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/providers/task_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/qr_screen.dart';
import 'package:flutter_application_1/screens/scanner_screen.dart';
import 'package:flutter_application_1/providers/preference_provider.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).setUser(widget.user.id!);
    });
  }

  void _showTaskDialog({Task? task}) {
    final _titleController = TextEditingController(text: task?.title ?? '');
    final _descriptionController =
        TextEditingController(text: task?.description ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'Tugas Baru' : 'Edit Tugas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                autofocus: true,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final newTask = Task(
                    id: task?.id,
                    userId: widget.user.id!,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    isCompleted: task?.isCompleted ?? false,
                  );
                  if (task == null) {
                    Provider.of<TaskProvider>(context, listen: false)
                        .addTask(newTask);
                  } else {
                    Provider.of<TaskProvider>(context, listen: false)
                        .updateTask(newTask);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${widget.user.email ?? 'User'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScannerScreen(userId: widget.user.id!),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              final provider = Provider.of<ThemeProvider>(context, listen: false);
              final newMode = provider.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              provider.setThemeMode(newMode);
            },
          ),
          PopupMenuButton<dynamic>(
            onSelected: (value) {
              if (value is TaskFilter) {
                Provider.of<TaskProvider>(context, listen: false).setFilter(value);
              } else if (value is TaskSortOption) {
                Provider.of<PreferenceProvider>(context, listen: false)
                    .setSortOption(value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskFilter.all,
                child: Text('Filter: Semua'),
              ),
              const PopupMenuItem(
                value: TaskFilter.completed,
                child: Text('Filter: Selesai'),
              ),
              const PopupMenuItem(
                value: TaskFilter.pending,
                child: Text('Filter: Belum Selesai'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: TaskSortOption.none,
                child: Text('Urutkan: Normal'),
              ),
              const PopupMenuItem(
                value: TaskSortOption.byTitle,
                child: Text('Urutkan: Judul'),
              ),
              const PopupMenuItem(
                value: TaskSortOption.byDueDate,
                child: Text('Urutkan: Tanggal'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.tasks.isEmpty) {
            return const Center(child: Text('Belum ada tugas. Tambahkan satu!'));
          }
          return ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    final updatedTask = Task(
                      id: task.id,
                      userId: task.userId,
                      title: task.title,
                      description: task.description,
                      isCompleted: value ?? false,
                      dueDate: task.dueDate,
                    );
                    Provider.of<TaskProvider>(context, listen: false)
                        .updateTask(updatedTask);
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrScreen(task: task),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showTaskDialog(task: task);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Provider.of<TaskProvider>(context, listen: false)
                            .deleteTask(task.id!);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 