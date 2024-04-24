import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:simple_todo_app/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType boardType,
  required String label,
  required IconData prefix,
  required String? Function(String?)? validate,
  void Function(String)? onChange,
  void Function(String)? onSubmit,
  void Function()? onTap,
  IconData? suffix,
  bool obscure = false,
  Function()? suffixPressed,
}) =>
    TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: boardType,
      onTap: onTap,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validate!,
      decoration: InputDecoration(
        //contentPadding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelText: label,
        prefixIcon: Icon(prefix),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed,
                icon: Icon(suffix),
              )
            : null,
      ),
    );

Widget tasksBuilder({
  required List<Map> tasks,
}) {
  return ConditionalBuilder(
    condition: tasks.isNotEmpty,
    builder: (context) => ListView.separated(
      itemBuilder: (context, index) => buildTasksItems(
        record: tasks[index],
        context: context,
      ),
      separatorBuilder: (context, index) => buildSeparatorWidget(),
      itemCount: tasks.length,
    ),
    fallback: (context) => buildFallBackWidget(),
  );
}

/// fallback
Widget buildFallBackWidget() {
  return const Center(
    child: Text(
      'No Tasks Yet',
      style: TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );
}

/// separatorBuilder
Widget buildSeparatorWidget() {
  return Padding(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 20.0),
    child: Container(
      height: 1.0,
      width: double.infinity,
      color: Colors.grey[400],
    ),
  );
}

/// itemBuilder
Widget buildTasksItems({
  required Map record,
  required BuildContext context,
}) =>
    Dismissible(
      // لو عايز احركها يمين او شمال
      key: Key(record['ID'].toString()), // key has string
      onDismissed: (direction) {
        // هنا هقوله لما اسحب يمين او شمال اي اللي المفروض يحصل
        ToDoAppCubit.get(context).deleteFromDatabase(id: record['ID']);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text(record['time']),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    record['date'],
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            IconButton(
              // to update status to done
              onPressed: () {
                ToDoAppCubit.get(context).updateInToDatabase(
                  status: 'done',
                  id: record['ID'],
                );
              },
              icon: const Icon(
                Icons.check_box,
                color: Colors.green,
              ),
            ),
            IconButton(
              // to update status to archive
              onPressed: () {
                ToDoAppCubit.get(context).updateInToDatabase(
                  status: 'archive',
                  id: record['ID'],
                );
              },
              icon: const Icon(
                Icons.archive,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
