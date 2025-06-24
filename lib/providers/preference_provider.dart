import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaskSortOption { none, byTitle, byDueDate }

class PreferenceProvider with ChangeNotifier {
  TaskSortOption _sortOption = TaskSortOption.none;
  static const String _sortOptionKey = 'sortOption';

  TaskSortOption get sortOption => _sortOption;

  PreferenceProvider() {
    _loadSortOption();
  }

  void _loadSortOption() async {
    final prefs = await SharedPreferences.getInstance();
    final sortIndex = prefs.getInt(_sortOptionKey) ?? TaskSortOption.none.index;
    _sortOption = TaskSortOption.values[sortIndex];
    notifyListeners();
  }

  Future<void> setSortOption(TaskSortOption option) async {
    _sortOption = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortOptionKey, option.index);
    notifyListeners();
  }
} 