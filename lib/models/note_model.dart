import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  bool isChecklist;

  @HiveField(4)
  List<ChecklistItem>? checklist;

  @HiveField(5)
  DateTime date;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isChecklist = false,
    this.checklist,
    required this.date,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isChecklist,
    List<ChecklistItem>? checklist,
    DateTime? date,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isChecklist: isChecklist ?? this.isChecklist,
      checklist: checklist ?? this.checklist,
      date: date ?? this.date,
    );
  }
}

@HiveType(typeId: 1)
class ChecklistItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  bool isDone;

  ChecklistItem({
    String? id,
    required this.text,
    this.isDone = false,
  }) : id = id ?? '${DateTime.now().millisecondsSinceEpoch}_${text.hashCode}';

  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? isDone,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }
}
