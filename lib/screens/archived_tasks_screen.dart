import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_todo_app/components.dart';
import 'package:simple_todo_app/cubit/cubit.dart';
import 'package:simple_todo_app/cubit/states.dart';

class ArchivedTasksScreen extends StatelessWidget {
  const ArchivedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ToDoAppCubit,ToDoAppStates>(
      listener: (BuildContext context,ToDoAppStates state){},
      builder: (BuildContext context,ToDoAppStates state){
        List<Map> tasks = ToDoAppCubit.get(context).recordsArchiveTasks;

        return tasksBuilder(tasks: tasks);
      },
    );
  }
}
