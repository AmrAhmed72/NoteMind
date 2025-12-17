import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';

class ChecklistScreen extends StatefulWidget {
  final Note note;

  const ChecklistScreen({super.key, required this.note});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late TextEditingController _titleController;
  late TextEditingController _newItemController;
  late List<ChecklistItem> _items;
  final FocusNode _newItemFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _newItemController = TextEditingController();
    _items = widget.note.checklist?.map((item) {
      final newId = item.id ?? UniqueKey().toString(); // تأكيد id فريد
      print('ChecklistItem - id: $newId, text: ${item.text}, isDone: ${item.isDone}'); // للتحقق
      return ChecklistItem(
        id: newId,
        text: item.text,
        isDone: item.isDone,
      );
    }).toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _newItemController.dispose();
    _newItemFocusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _newItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add(ChecklistItem(
          id: UniqueKey().toString(), // إضافة id فريد
          text: text,
          isDone: false,
        ));
        _newItemController.clear();
      });
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index] = _items[index].copyWith(isDone: !_items[index].isDone);
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _saveChecklist() async {
    final title = _titleController.text.trim();

    if (title.isEmpty && _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checklist is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedNote = widget.note.copyWith(
      title: title,
      checklist: _items,
      date: DateTime.now(),
    );

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    if (widget.note.title.isEmpty && (widget.note.checklist?.isEmpty ?? true)) {
      await notesProvider.addNote(updatedNote);
    } else {
      await notesProvider.updateNote(updatedNote);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Checklist saved!'),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _convertToTextNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to Text Note'),
        content: const Text(
          'This will convert your checklist to a regular text note. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final content = _items.map((item) {
                return '${item.isDone ? '✓' : '○'} ${item.text}';
              }).join('\n');

              final textNote = widget.note.copyWith(
                isChecklist: false,
                content: content,
                checklist: null,
              );

              Provider.of<NotesProvider>(context, listen: false)
                  .updateNote(textNote);

              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close checklist screen
            },
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _items.where((item) => item.isDone).length;
    final progress = _items.isEmpty ? 0.0 : completedCount / _items.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: _convertToTextNote,
            tooltip: 'Convert to text note',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChecklist,
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                  ),
              decoration: InputDecoration(
                hintText: 'Checklist Title',
                hintStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                      color: Colors.grey,
                    ),
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, end: 0),

          // Progress indicator
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedCount of ${_items.length} completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scaleX(begin: 0, end: 1, alignment: Alignment.centerLeft),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Checklist items
          Expanded(
            child: _items.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.checklist_outlined,
                    size: 80,
                    color: Colors.grey,
                  )
                      .animate()
                      .fadeIn(duration: 1000.ms)
                      .scale(delay: 200.ms),
                  const SizedBox(height: 16),
                  Text(
                    'No items yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first item below',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
                : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                print('Building item at index $index, id: ${item.id}, text: ${item.text}');
                if (item.id == null) {
                  print('Error: Item at index $index has null id');
                  return const SizedBox.shrink();
                }
                return Dismissible(
                  key: ValueKey('${item.id}_$index'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteItem(index),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: _buildChecklistItem(index),
                );
              },
            ),
          ),
          // Add new item field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    focusNode: _newItemFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Add new item',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _addItem,
                  mini: true,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(int index) {
    final item = _items[index];
    print('Building _buildChecklistItem at index $index, id: ${item.id}, text: ${item.text}');

    return Dismissible(
      key: ValueKey('${item.id}_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteItem(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Checkbox(
            value: item.isDone,
            onChanged: (_) => _toggleItem(index),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            item.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              decoration: item.isDone ? TextDecoration.lineThrough : null,
              color: item.isDone
                  ? Colors.grey
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
