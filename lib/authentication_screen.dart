import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:todo_app/ids.dart';
import 'todo_list_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final Client appwriteClient = Client();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String? email;
  late String? userId;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    appwriteClient
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(AppwriteIDs.projectID);
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  Future<void> signUp(String email, String password) async {
    try {
      await Account(appwriteClient).create(
        email: email,
        password: password,
        name: email,
        userId: userId!,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TodoListScreen(email: emailController.text)),
      );
    } catch (e) {
      // Show error popup
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await Account(appwriteClient).createEmailSession(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TodoListScreen(email: emailController.text)),
      );
    } catch (e) {
      // Show error popup
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo: Organize yourself ;)',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // Change app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    signUp(emailController.text, passwordController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple, // Change button color
                ),
                child: const Text('Sign Up',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    signIn(emailController.text, passwordController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple, // Change button color
                ),
                child: const Text('Sign In',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
