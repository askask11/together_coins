import 'package:flutter/material.dart';

class UserTasksPage extends StatelessWidget {
  int whoseTask = -1; // -1 is my task, anything else is other's task

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Created Tasks 📝'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Button to Create a New Task
            ElevatedButton(
              onPressed: () {
                // Handle create new task
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text("Create New Task ➕",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),

            // List of Created Tasks
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: 5, // Example count for user-created tasks
                itemBuilder: (context, index) {
                  return TaskCard(
                    taskTitle: "Task ${index + 1}",
                    taskDescription:
                        "Description for created task ${index + 1}.",
                    status: "In Progress",
                    statusColor: Colors.blue,
                    dueDate: "Due: 2024-12-10",
                    amount: "50 Coins",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String taskTitle;
  final String taskDescription;
  final String status;
  final Color statusColor;
  final String dueDate;
  final String amount;

  TaskCard({
    required this.taskTitle,
    required this.taskDescription,
    required this.status,
    required this.statusColor,
    required this.dueDate,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              taskTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              dueDate,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              amount,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 14,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
