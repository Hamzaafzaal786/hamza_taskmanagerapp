import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  int get completedCount {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int get totalCount => _tasks.length;

  // Load tasks from SharedPreferences
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks_list');
    
    if (tasksJson != null) {
      List<dynamic> decodedList = json.decode(tasksJson);
      _tasks = decodedList.map((item) => Task.fromMap(item)).toList();
      notifyListeners(); // Update UI
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> tasksMap = _tasks.map((task) => task.toMap()).toList();
    String tasksJson = json.encode(tasksMap);
    await prefs.setString('tasks_list', tasksJson);
  }

  // Add new task
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;
    
    _tasks.add(Task(title: title.trim()));
    await _saveTasks();
    notifyListeners(); // Update UI
  }

  // Delete task
  Future<void> deleteTask(int index) async {
    _tasks.removeAt(index);
    await _saveTasks();
    notifyListeners(); // Update UI
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(int index) async {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    await _saveTasks();
    notifyListeners(); // Update UI
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _saveTasks();
    notifyListeners(); // Update UI
  }
}