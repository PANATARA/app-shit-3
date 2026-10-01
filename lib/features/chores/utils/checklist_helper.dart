import '../models/subtask_model.dart';

class ChecklistHelper {
  ChecklistHelper._();

  static final RegExp _checklistRegex = RegExp(r'^\s*[-*]\s*\[([ xX])\]\s*(.*)$');
  static int _idCounter = 0;

  static String _generateId() {
    _idCounter++;
    return 'st_${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }

  static ParsedMessage parseMessage(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const ParsedMessage(description: '', subtasks: []);
    }

    final lines = raw.split(RegExp(r'\r?\n'));
    final descriptionLines = <String>[];
    final subtasks = <Subtask>[];

    for (final line in lines) {
      final match = _checklistRegex.firstMatch(line);
      if (match != null) {
        final mark = match.group(1)?.toLowerCase() ?? ' ';
        final text = match.group(2)?.trim() ?? '';
        subtasks.add(
          Subtask(
            id: _generateId(),
            text: text,
            done: mark == 'x',
          ),
        );
      } else {
        descriptionLines.add(line);
      }
    }

    return ParsedMessage(
      description: descriptionLines.join('\n').trim(),
      subtasks: subtasks,
    );
  }

  static String serializeMessage(String description, List<Subtask> subtasks) {
    final cleanDesc = description.trim();
    final validSubtasks = subtasks.where((st) => st.text.trim().isNotEmpty).toList();

    final subtaskLines = validSubtasks.map((st) {
      final mark = st.done ? 'x' : ' ';
      return '- [$mark] ${st.text.trim()}';
    }).toList();

    if (subtaskLines.isEmpty) {
      return cleanDesc;
    }

    if (cleanDesc.isEmpty) {
      return subtaskLines.join('\n');
    }

    return '$cleanDesc\n${subtaskLines.join('\n')}';
  }
}
