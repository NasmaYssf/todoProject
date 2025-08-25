class Todo {
  int? id;     // Clé primaire locale
  int? todoId;  // ID du serveur
  String todo;
  String? date;
  int? LocalTodoId;
  bool isCompleted;
  int? userId;

  Todo({
    this.id,
    this.todoId,
    this.LocalTodoId,
    required this.todo,
    required this.date,
    required this.isCompleted,
    required this.userId,
  });

  factory Todo.fromMap(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int?,
      todoId: json['todo_id'] as int?,
      LocalTodoId: json['LocalTodoId'] ?? json['Local_TodoId'],
      todo: json['todo'] ?? '',
      date: (json['date'] ?? '').toString(),
      isCompleted: json['done'].toString() == "1",
      userId: json['account_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todo_id': todoId,
      'LocalTodoId': LocalTodoId,
      'todo': todo,
      'date': date,
      'done': isCompleted ? 1 : 0,
      'account_id': userId,
    };
  }

  Todo copyWith({
    int? id,
    int? todoId,
    int? userId,
    String? todo,
    String? date,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      LocalTodoId: LocalTodoId ?? this.LocalTodoId,
      userId: userId ?? this.userId,
      todo: todo ?? this.todo,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}