import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/providers/preference_provider.dart';
import 'package:flutter_application_1/services/database_helper.dart';

enum TaskFilter { all, completed, pending }

class TaskProvider with ChangeNotifier {
  List<Task> _allTasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late String _userId;
  TaskFilter _filter = TaskFilter.all;
  TaskSortOption? _sortOption;

  TaskProvider(this._sortOption);

  void updateSortOption(TaskSortOption sortOption) {
    _sortOption = sortOption;
    notifyListeners();
  }

  List<Task> get tasks {
    // 1. Filtering
    List<Task> filteredTasks;
    switch (_filter) {
      case TaskFilter.completed:
        filteredTasks = _allTasks.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.pending:
        filteredTasks = _allTasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.all:
      default:
        filteredTasks = _allTasks;
    }

    // 2. Sorting
    if (_sortOption != null) {
      switch (_sortOption!) {
        case TaskSortOption.byTitle:
          filteredTasks.sort((a, b) => a.title.compareTo(b.title));
          break;
        case TaskSortOption.byDueDate:
          filteredTasks.sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          });
          break;
        case TaskSortOption.none:
          break;
      }
    }

    return filteredTasks;
  }

  TaskFilter get filter => _filter;

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setUser(String userId) {
    _userId = userId;
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    _allTasks = await _dbHelper.getTasks(_userId);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _dbHelper.createTask(task);
    fetchTasks(); // Refetch to update the list
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
    fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    fetchTasks();
  }
} 