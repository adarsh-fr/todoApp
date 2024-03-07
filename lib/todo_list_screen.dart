// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:todo_app/authentication_screen.dart';
import 'package:todo_app/ids.dart';

class TodoListScreen extends StatefulWidget {
  final String? email;

  const TodoListScreen({super.key, required this.email});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final Client appwriteClient = Client();
  late Databases database;
  late List<Document> todos = [];
  late TextEditingController todoController;

  @override
  void initState() {
    super.initState();
    appwriteClient
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(AppwriteIDs.projectID);

    database = Databases(appwriteClient);
    todoController = TextEditingController();

    getTodos();
  }

  Future<void> getTodos() async {
    try {
      DocumentList response = await database.listDocuments(
        collectionId: AppwriteIDs.collectionID,
        databaseId: AppwriteIDs.databaseID,
        queries: [
          Query.equal('email', widget.email),
        ],
      );
      setState(() {
        todos = response.documents;
      });
    } catch (e) {
      // Show error popup
    }
  }

  Future<void> addTodo(String todo) async {
    try {
      String documentId = ID.unique();
      await database.createDocument(
        collectionId: AppwriteIDs.collectionID,
        data: {'title': todo, 'completed': false, 'email': widget.email},
        databaseId: AppwriteIDs.databaseID,
        documentId: documentId,
      );
      todoController.clear();
      getTodos();
    } catch (e) {
      // Show error popup
    }
  }

  Future<void> toggleTodoStatus(Document todo) async {
    try {
      await database.updateDocument(
        collectionId: AppwriteIDs.collectionID,
        data: {'completed': !todo.data['completed']},
        databaseId: AppwriteIDs.databaseID,
        documentId: todo.$id,
      );
      getTodos();
    } catch (e) {
      // Show error popup
    }
  }

  Future<void> deleteTodo(Document todo) async {
    try {
      await database.deleteDocument(
        collectionId: AppwriteIDs.collectionID,
        documentId: todo.$id,
        databaseId: AppwriteIDs.databaseID,
      );
      getTodos();
    } catch (e) {
      // Show error popup
    }
  }

  Future<void> logout() async {
    try {
      await Account(appwriteClient).deleteSession(sessionId: 'current');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthenticationScreen(),
        ),
      );
    } catch (e) {
      // Show error popup
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do List',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white,),
            onPressed: logout,
            
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return GestureDetector(
            onTap: () => toggleTodoStatus(todo),
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: todo.data['completed'] ? Colors.grey[300] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: todo.data['completed'],
                      onChanged: (_) => toggleTodoStatus(todo),
                      checkColor: Colors.white,
                      activeColor: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        todo.data['title'],
                        style: TextStyle(
                          fontSize: 18,
                          decoration: todo.data['completed']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteTodo(todo),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add Todo'),
                content: TextField(
                  controller: todoController,
                  decoration: const InputDecoration(hintText: 'Enter your todo'),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      if (todoController.text.isNotEmpty) {
                        addTodo(todoController.text);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }
}