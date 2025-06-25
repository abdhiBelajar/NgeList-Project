import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/task_provider.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime _selectedDay = DateTime.now();

  void _prevDay() {
    setState(() {
      _selectedDay = _selectedDay.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    if (!_isToday(_selectedDay)) {
      setState(() {
        _selectedDay = _selectedDay.add(const Duration(days: 1));
      });
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          final completed = taskProvider.tasks.where((t) => t.isCompleted).length;
          final pending = taskProvider.tasks.where((t) => !t.isCompleted).length;
          final streak = 7;

          // Untuk grafik mingguan
          DateTime weekStart = _selectedDay.subtract(Duration(days: _selectedDay.weekday % 7));
          List<int> weeklyCompletion = List.filled(7, 0);
          for (var t in taskProvider.tasks) {
            if (t.isCompleted && t.dueDate != null) {
              // Hitung index hari: Min=0, Sen=1, ..., Sab=6
              int weekdayIndex = t.dueDate!.weekday % 7; // Sen=1, ..., Min=7 -> Min=0, Sen=1, ..., Sab=6
              DateTime barDate = weekStart.add(Duration(days: weekdayIndex));
              if (t.dueDate!.year == barDate.year && t.dueDate!.month == barDate.month && t.dueDate!.day == barDate.day) {
                weeklyCompletion[weekdayIndex]++;
              }
            }
          }

          // Untuk detail satu hari
          int completedToday = taskProvider.tasks.where((t) =>
            t.isCompleted &&
            t.dueDate != null &&
            t.dueDate!.year == _selectedDay.year &&
            t.dueDate!.month == _selectedDay.month &&
            t.dueDate!.day == _selectedDay.day
          ).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Info Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hai ${widget.user.email?.split('@')[0] ?? 'User'}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Pertahankan rencana selama $streak hari'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Task Summary Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('$completed', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                const Text('Tugas Selesai'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text('$pending', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                const Text('Tugas Tertunda'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Weekly Completion Chart (Bar)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Penyelesaian tugas harian', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (i) {
                            final barHeight = weeklyCompletion[i] * 16.0;
                            final barDate = weekStart.add(Duration(days: i));
                            final isSelected = barDate.year == _selectedDay.year && barDate.month == _selectedDay.month && barDate.day == _selectedDay.day;
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: barHeight,
                                    width: 16,
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue : Colors.blue[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(['Min','Sen','Sel','Rab','Kam','Jum','Sab'][i], style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Daily Completion Card (per hari)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: _prevDay,
                          ),
                          Text('Detail hari', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: _isToday(_selectedDay) ? null : _nextDay,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '${_selectedDay.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              height: completedToday * 40.0,
                              width: 32,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('$completedToday tugas selesai', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 