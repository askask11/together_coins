import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:together_coins/get_env.dart';

import '../user.dart';
import 'task.dart';

class EditCreateTaskPage extends StatelessWidget {
  final int taskId;
  final User user;
  final User bindUser;
  final String? taskTitle;
  final String? taskDescription;
  final String? dueDate;
  final String? amount;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  EditCreateTaskPage({
    required this.taskId, //if 0, then adding new task
    required this.user,
    required this.bindUser,
    this.taskTitle,
    this.taskDescription,
    this.dueDate,
    this.amount,
  });

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Saving Task'),
          content: SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  void saveTask(BuildContext context) {
    // Save Task action
    //shows loading dialog

    // Get the values from the text controllers
    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final String dueDate = _dueDateController.text;
    final String amount = _amountController.text;

    // Validate the values
    if (title.isEmpty ||
        description.isEmpty ||
        dueDate.isEmpty ||
        amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all the fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // validate due date. if in edit mode, due date should be in yyyy-mm-dd format and then we convert it to number of days from today and check if it's valid, else in number of days.
    //we need to ensure that the number of days are positive after conversion
    int numDays = 0;
    if (taskId == 0) {
      numDays = int.tryParse(dueDate) ?? 0;
      if (numDays <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid number of days.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      DateTime dueDateObj = DateTime.tryParse(dueDate) ?? DateTime.now();
      if (dueDateObj.isBefore(DateTime.now()) ||
          dueDateObj.isAtSameMomentAs(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid due date.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      numDays = dueDateObj.difference(DateTime.now()).inDays;
    }

    showLoadingDialog(context);
    //server accepts title, description, num_days, num_days_accept, amount;

    //send a POST request to the server
    http.post(
        Uri.parse(
            "${GetEnv.getApiBaseUrl()}/task/${taskId == 0 ? 'create' : 'edit'}"),
        headers: <String, String>{
          //'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.jwtToken}',
        },
        body: {
          "task_id": taskId.toString(),
          "title": title,
          "description": description,
          "num_days": numDays.toString(),
          "num_days_accept": numDays.toString(),
          "amount": amount,
          "by_user": user.userId.toString(),
          //"to_user": bindUser.userId.toString(),
        }).then((response) {
      Navigator.of(context).pop();
      if (response.statusCode > 199 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Task ${taskId == 0 ? 'created' : 'edited'} successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (response.statusCode == 403) {
        //user timed out
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are timed out. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${taskId == 0 ? 'create' : 'edit'} task. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).catchError((onError, stackTrace) {
      print(onError);
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  EditCreateTaskPage.edit(Task task, User user, User bindUser)
      : this(
            taskId: task.task_id,
            user: user,
            bindUser: bindUser,
            taskTitle: task.title,
            taskDescription: task.description,
            dueDate: task.getDueDateFormatted(),
            amount: task.numCoins.toString());

  EditCreateTaskPage.add(User user, User bindUser)
      : this(taskId: 0, user: user, bindUser: bindUser);

  Future<void> onRefresh() async {
    //do nothing
  }

  @override
  Widget build(BuildContext context) {
    //set text for tec
    _titleController.text = taskTitle ?? "";
    _descriptionController.text = taskDescription ?? "";
    _dueDateController.text = dueDate ?? "";
    _amountController.text = amount ?? "";

    return Scaffold(
      appBar: AppBar(
        /*actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Row(
                children: [
                  Text(
                    'Coins: 1000',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.monetization_on, color: Colors.yellowAccent),
                ],
              ),
            ),
          ),
        ],*/
        title: Text(taskId == 0 ? 'Create Task ✨' : 'Edit Task ✨',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task Title Input
            TaskInputField(
              controller: _titleController,
              labelText: 'Task Title 📝',
            ),
            SizedBox(height: 16),

            // Task Description Input
            TaskInputField(
              controller: _descriptionController,
              labelText: 'Task Description ✍️',
              maxLines: 4,
            ),
            SizedBox(height: 16),

            // Task Due Date Input
            TaskInputField(
              controller: _dueDateController,
              labelText: taskId == 0
                  ? 'Number of days to complete'
                  : 'Due Date 📅 (YYYY-MM-DD)',
            ),
            SizedBox(height: 16),

            // Task Amount Input
            TaskInputField(
              controller: _amountController,
              labelText: 'Reward Amount 💰 (Coins)',
            ),
            SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Save Task action
                saveTask(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: EdgeInsets.symmetric(vertical: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 10,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Save Task',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.favorite, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int maxLines;

  TaskInputField({
    required this.controller,
    required this.labelText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
            TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pinkAccent, width: 2.0),
          borderRadius: BorderRadius.circular(20.0),
        ),
        filled: true,
        fillColor: Colors.pink[50],
      ),
    );
  }
}
