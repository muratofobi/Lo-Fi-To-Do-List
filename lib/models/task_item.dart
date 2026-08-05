class TaskItem {
  String id;
  String title;
  DateTime date;
  bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
  });
}
