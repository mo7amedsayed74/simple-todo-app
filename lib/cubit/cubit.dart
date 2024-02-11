import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_todo_app/cubit/states.dart';
import 'package:simple_todo_app/screens/archived_tasks_screen.dart';
import 'package:simple_todo_app/screens/done_tasks_screen.dart';
import 'package:simple_todo_app/screens/new_tasks_screen.dart';
import 'package:sqflite/sqflite.dart';

class ToDoAppCubit extends Cubit<ToDoAppStates> {
  ToDoAppCubit() : super(InitialState());

  // to be more easily when use this cubit (Bloc)
  static ToDoAppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeCurrentIndex(index){
    currentIndex = index;
    emit(SwapBottomNavBar());
  }



  /// Database
  Database? database;
  List<Map>recordsNewTasks=[];
  List<Map>recordsDoneTasks=[];
  List<Map>recordsArchiveTasks=[];

  void createDatabase() {
    //debugPrint('function is called');
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        debugPrint('database created');

        // create tables
        database.execute(
          'create table tasks(ID INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)',
        ).then((value) {
          debugPrint('Table created');
        }).catchError((error) {
          debugPrint('Error when creating Table : ${error.toString()}');
        });
        // end execute
      },
      onOpen: (database) {
        debugPrint('database opened');
        getRecordsFromDatabase(database);
      },
    ).then((value) {
      database = value; // value is the created database
      emit(CreateDatabaseState());
    });
  } // createDatabase

  insertToDatabase({
    required title,
    required date,
    required time,
  }) async {
    await database!.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO tasks(title,date,time,status) VALUES("$title" , "$date" , "$time" , "new")',
      ).then((value) {
        // this value is the ID to this insertedRow
        debugPrint('ID : $value inserted successfully');
        emit(InsertToDatabaseState());

        getRecordsFromDatabase(database);

      }).catchError((error) {
        debugPrint('ERROR! : ${error.toString()}');
      });

      //return Future.value();
    }); // end transaction

  } // insertToDatabase

  void getRecordsFromDatabase(database)async{
    recordsNewTasks=[];
    recordsDoneTasks=[];
    recordsArchiveTasks=[];

    emit(GetRecordsLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((row){ // value >> is a returned list<map>
        if(row['status']=='done') {
          recordsDoneTasks.add(row);
        }else if(row['status']=='archive') {
          recordsArchiveTasks.add(row);
        }else {
          recordsNewTasks.add(row);
        }
      }); // end of loop

      emit(GetRecordsFromDatabaseState());
    });
  }

  void updateInToDatabase({
    required String status,
    required int id,})async
  {
    await database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE ID = ?', [status, id]
    ).then((value) {
      getRecordsFromDatabase(database);
      emit(UpdateInToDatabaseState());
    });

  }

  void deleteFromDatabase({
    required int id,
  })async {
    await database!.rawDelete(
        'DELETE FROM tasks WHERE ID = ?', [id]
    ).then((value) {
      getRecordsFromDatabase(database);
      emit(DeleteFromDatabaseState());
    });

  }


  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool isShown,
    required IconData icon,
}){
    isBottomSheetShown = isShown;
    fabIcon = icon;
    emit(SwapBottomSheetState());
}

}
