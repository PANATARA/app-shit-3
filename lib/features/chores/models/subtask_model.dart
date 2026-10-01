class Subtask {
  final String id;
  final String text;
  final bool done;

  const Subtask({
    required this.id,
    required this.text,
    this.done = false,
  });

  Subtask copyWith({
    String? id,
    String? text,
    bool? done,
  }) {
    return Subtask(
      id: id ?? this.id,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}

class ParsedMessage {
  final String description;
  final List<Subtask> subtasks;

  const ParsedMessage({
    required this.description,
    required this.subtasks,
  });

  bool get hasSubtasks => subtasks.isNotEmpty;
}
