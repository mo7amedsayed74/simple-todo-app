import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:simple_todo_app/components.dart';
import 'package:simple_todo_app/cubit/cubit.dart';
import 'package:simple_todo_app/cubit/states.dart';

// 1. create database
// 2. create tables
// 3. open database
// 4. insert to database
// 5. get from database
// 6. update in database
// 7. delete from database

class ToDoLayout extends StatelessWidget {
  ToDoLayout({super.key});

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var textController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ToDoAppCubit()..createDatabase(),
      child: BlocConsumer<ToDoAppCubit,ToDoAppStates>(
        listener: (BuildContext context,ToDoAppStates state){
          if(state is InsertToDatabaseState){
            // reset fields
            textController.text = '';
            timeController.text = '';
            dateController.text = '';
            // close bottom sheet
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context,ToDoAppStates state){
          ToDoAppCubit cubit = ToDoAppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
              centerTitle: true,
              elevation: 0.0,
            ),
            //body: recordsTasks.isNotEmpty ? screens[currentIndex] : const Center(child: CircularProgressIndicator()),
            body: ConditionalBuilder(
              condition: state is! GetRecordsLoadingState , //recordsTasks.isNotEmpty
              builder: (context) => cubit.screens[cubit.currentIndex], // if condition >> true
              fallback: (context) => const Center(child: CircularProgressIndicator()), // if condition >> false
            ),
            floatingActionButton: FloatingActionButton(
              splashColor: Colors.yellow, // اللون اللي بيظهر لما اضغط على الزرار
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    // insert new task in database
                    cubit.insertToDatabase(
                      time: timeController.text,
                      date: dateController.text,
                      title: textController.text,
                    ); // then >> (reset fields && close bottom sheet) in listener
                  }
                } else {
                  scaffoldKey.currentState?.showBottomSheet(
                        (context) => Container(
                          padding: const EdgeInsets.all(10),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  label: 'Task Title',
                                  prefix: Icons.text_fields,
                                  validate: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Text must not be empty';
                                    }
                                    return null;
                                  },
                                  controller: textController,
                                  boardType: TextInputType.text,
                                ),
                                const SizedBox(
                                  height: 10
                                ),
                                defaultFormField(
                                  label: 'Task Time',
                                  prefix: Icons.access_time,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      if (value != null) {
                                        timeController.text = value.format(context).toString();
                                      }
                                    });
                                  },
                                  validate: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Time must not be empty';
                                    }
                                    return null;
                                  },
                                  controller: timeController,
                                  boardType: TextInputType.none,
                                ),
                                const SizedBox(
                                  height: 10
                                ),
                                defaultFormField(
                                  label: 'Task Date',
                                  prefix: Icons.calendar_month,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2055-12-29'),
                                    ).then((value) {
                                      // install package (intl: ^0.18.1) to date format
                                      dateController.text = DateFormat.yMMMd().format(value!);
                                    });
                                  },
                                  validate: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Date must not be empty';
                                    }
                                    return null;
                                  },
                                  controller: dateController,
                                  boardType: TextInputType.none,
                                ),
                              ],
                            ),
                          ),
                        ),
                  ).closed.then((value) {
                    cubit.changeBottomSheetState(
                      icon: Icons.edit,
                      isShown: false,
                    );
                  });

                  cubit.changeBottomSheetState(
                    isShown: true,
                    icon: Icons.add,
                  );
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              elevation: 60.0,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeCurrentIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_box_outlined,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}


