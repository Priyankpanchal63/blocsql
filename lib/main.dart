import 'package:blocsql/ui/Crud_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/crud_bloc.dart';
import 'bloc/crud_event.dart';
import 'bloc/crud_state.dart';
import 'databse/databse.dart';
import 'model/crud_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UserBloc(DatabaseHelper())..add(LoadUsers()),
        child: HomePage(),
      ),
    );
  }
}
