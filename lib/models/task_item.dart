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

  // YENİ: Hafızaya yazmak için veriyi JSON (metin) formatına dönüştürür
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'isCompleted': isCompleted,
  };

  // YENİ: Hafızadan okurken metni tekrar TaskItem objesine dönüştürür
  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'],
    title: json['title'],
    date: DateTime.parse(json['date']),
    isCompleted: json['isCompleted'],
  );
}
