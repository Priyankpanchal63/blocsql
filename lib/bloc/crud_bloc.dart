import 'package:bloc/bloc.dart';
import 'package:blocsql/bloc/crud_event.dart';
import 'package:blocsql/bloc/crud_state.dart';
import 'package:blocsql/databse/databse.dart';
import '../model/crud_model.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final DatabaseHelper dbHelper;

  UserBloc(this.dbHelper) : super(UserInitial()) {
    // Load users event
    on<LoadUsers>((event, emit) async {
      emit(UserLoading()); // Show loading while fetching data
      try {
        final users = await dbHelper.getUser();
        emit(UserLoaded(users.map((e) => User.fromMap(e)).toList()));
      } catch (e) {
        emit(UserError(e.toString())); // Emit error if something goes wrong
      }
    });

    // Add user event
    on<AddUser>((event, emit) async {
      await dbHelper.insertUser(event.user.toMap());
      final users = await dbHelper.getUser();
      emit(UserLoaded(users.map((e) => User.fromMap(e)).toList())); // Emit updated list
    });

    // Update user event
    on<UpdateUser>((event, emit) async {
      await dbHelper.updateUser(event.user.toMap());
      final users = await dbHelper.getUser();
      emit(UserLoaded(users.map((e) => User.fromMap(e)).toList())); // Emit updated list
    });

    // Delete user event
    on<DeleteUser>((event, emit) async {
      await dbHelper.deleteUser(event.id);
      final users = await dbHelper.getUser();
      emit(UserLoaded(users.map((e) => User.fromMap(e)).toList())); // Emit updated list
    });
  }
}
