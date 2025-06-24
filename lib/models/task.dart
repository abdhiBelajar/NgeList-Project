class Task {
  final int? id;
  final String userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // SQLite uses 0 and 1 for booleans
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }
} 