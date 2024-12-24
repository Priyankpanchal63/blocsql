import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crud_bloc.dart';
import '../bloc/crud_event.dart';
import '../bloc/crud_state.dart';
import '../model/crud_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User? editingUser;

  void clearFields() {
    nameController.clear();
    ageController.clear();
    emailController.clear();
  }

  void saveUser() {
    final userBloc = BlocProvider.of<UserBloc>(context);

    if (formKey.currentState!.validate()) {
      final user = User(
        id: editingUser?.id, // Retain the ID if editing an existing user
        name: nameController.text.trim(),
        age: int.parse(ageController.text.trim()),
        email: emailController.text.trim(),
      );

      if (editingUser == null) {
        userBloc.add(AddUser(user));
      } else {
        userBloc.add(UpdateUser(user));
      }

      // Clear the fields after saving
      clearFields();
      setState(() {
        editingUser = null; // Reset the editing user
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD App with BLoC and SQLite")),
      body: Column(
        children: [
          // Form to Add/Update User
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: "Age"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Age is required";
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return "Enter a valid age";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                      if (!emailRegex.hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: saveUser,
                    child: Text(editingUser == null ? "Add User" : "Update User"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is UserLoaded) {
                  if (state.users.isEmpty) {
                    return Center(child: Text("No users found. Add a user."));
                  }
                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];

                      return Dismissible(
                        key: Key(user.id.toString()), // A unique key for each user
                        direction: DismissDirection.endToStart, // Swipe from right to left
                        onDismissed: (direction) {
                          BlocProvider.of<UserBloc>(context).add(DeleteUser(user.id!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${user.name} deleted')),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(user.name!),
                            subtitle: Text("Age: ${user.age}, Email: ${user.email}"),
                            onTap: () {
                              // Set fields for editing
                              setState(() {
                                nameController.text = user.name!;
                                ageController.text = user.age.toString();
                                emailController.text = user.email!;
                                editingUser = user; // Set the user for editing
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is UserError) {
                  return Center(child: Text(state.message));
                } else {
                  return Center(child: Text("Loading data..."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
