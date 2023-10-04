import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodosList extends StatefulWidget {
  TodosList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _TodosListState createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  final List<TodoItem> _todos = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String>? todoList = _prefs.getStringList('todos');
    if (todoList != null) {
      setState(() {
        _todos.addAll(todoList.map((todo) => TodoItem(todo)));
      });
    }
  }

  Future<void> _saveTodos() async {
    final List<String> todoList = _todos.map((todo) => todo.text).toList();
    await _prefs.setStringList('todos', todoList);
  }

  void _addTodo() async {
    final TextEditingController textEditingController = TextEditingController();

    final todoText = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return _buildAddTodoDialog(textEditingController);
      },
    );

    if (todoText != null && todoText.isNotEmpty) {
      final newTodo = TodoItem(todoText);
      setState(() {
        _todos.add(newTodo);
      });
      _saveTodos();
    }
  }

  AlertDialog _buildAddTodoDialog(TextEditingController textEditingController) {
    return AlertDialog(
      title: const Text('Add Todo'),
      content: TextField(
        controller: textEditingController,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter your task'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newTodo = textEditingController.text;
            if (newTodo.isNotEmpty) {
              Navigator.of(context).pop(newTodo);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  void _toggleTodoCompleted(int index) {
    setState(() {
      _todos[index].toggleCompleted();
    });
    _saveTodos();
  }

  Widget _buildTodoItem(int index) {
    final todoItem = _todos[index];
    return Dismissible(
      key: Key('$todoItem$index'),
      onDismissed: (direction) {
        _removeTodo(index);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        child: CheckboxListTile(
          title: Text(
            todoItem.text,
            style: TextStyle(
              decoration: todoItem.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          value: todoItem.isCompleted,
          onChanged: (bool? value) {
            _toggleTodoCompleted(index);
          },
          secondary: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _removeTodo(index);
            },
          ),
        ),
      ),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildTodoItem(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoItem {
  final String text;
  bool isCompleted;

  TodoItem(this.text, {this.isCompleted = false});

  void toggleCompleted() {
    isCompleted = !isCompleted;
  }
}
