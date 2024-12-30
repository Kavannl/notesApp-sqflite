import 'package:flutter/material.dart';
import '../database/notes_database.dart';

class NotesHomePage extends StatefulWidget {
  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final notes = await NotesDatabase.instance.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addOrUpdateNote({
    int? id,
    required String title,
    required String content,
  }) async {
    if (id == null) {
      await NotesDatabase.instance.insertNote(title, content);
    } else {
      await NotesDatabase.instance.updateNote(id, title, content);
    }
    _fetchNotes();
  }

  Future<void> _deleteNote(int id) async {
    await NotesDatabase.instance.deleteNote(id);
    _fetchNotes();
  }

  void _showNoteDialog({int? id, String? title, String? content}) {
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(id == null ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addOrUpdateNote(
                id: id,
                title: titleController.text,
                content: contentController.text,
              );
              Navigator.of(ctx).pop();
            },
            child: Text(id == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
            child: Text(
          'Notes App',
          style: TextStyle(
            color: Colors.white,
          ),
        )),
      ),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (ctx, index) {
          final note = _notes[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(note['title']),
              subtitle: Text(note['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showNoteDialog(
                      id: note['id'],
                      title: note['title'],
                      content: note['content'],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteNote(note['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showNoteDialog(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
