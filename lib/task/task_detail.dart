import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../get_env.dart';
import '../user.dart';
import 'task.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskTitle;
  final String postingUser;
  final String postingUserAvatar;
  final String description;
  final int status; // 0: To be accepted, 1: Accepted, 2: Rejected, 3: Completed
  final String taskImage;
  final String dueDate;
  final String acceptByDate;
  final String amount;
  final int task_id;

  final User user;

  TaskDetailPage({
    this.taskTitle = "Task Title",
    this.postingUser = "Posting User",
    this.postingUserAvatar = "https://via.placeholder.com/150",
    this.description = "Task Description",
    this.status = 0,
    this.taskImage = "",
    this.dueDate = "2024-12-10",
    this.acceptByDate = "2024-12-01",
    this.amount = "50 Coins",
    this.task_id = 0,
    required this.user,
  });

  TaskDetailPage.from(User user, User bindUser, Task task)
      : this(
          taskTitle: task.title,
          postingUser: bindUser.name,
          postingUserAvatar: GetEnv.iePath(bindUser.avatarPath),
          description: task.description,
          status: task.status,
          taskImage: "",
          dueDate: task.getDueDateFormatted(),
          acceptByDate: task.getDueDateFormatted(),
          amount: "${task.numCoins} Coins",
          task_id: task.task_id,
          user: user,
        );

  void updateStatus(BuildContext context, int status) async {
    // 🔑 /task/status
// Request: POST
// Body: task_id, status
// Response: Task status updated
    //show loading dialog
    //shows loading dialog with the fancy Alert
    Alert(
      context: context,
      title: "Updating Task Status",
      content: SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      type: AlertType.info,
    ).show();
    final response = await http.post(
      Uri.parse("${GetEnv.getApiBaseUrl()}/task/status"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.jwtToken}',
      },
      body: jsonEncode(<String, dynamic>{
        'task_id': task_id,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      // Task status updated
      Alert(
        context: context,
        title: "Task Status Updated",
        desc: "Task status updated successfully.",
        type: AlertType.success,
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            width: 120,
          )
        ],
      ).show();
    } else {
      // Task status update failed
      //parse the response body
      final Map<String, dynamic> body = jsonDecode(response.body);
      final String message = body['data'];
      if (body['status'] == "no_login") {
        //user timed out
        Alert(
          context: context,
          title: "You are Timed Out",
          desc: "You are timed out. For your security, Please login again.",
          type: AlertType.error,
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              width: 120,
            )
          ],
        ).show();
        return;
      }
      Alert(
        context: context,
        title: "Task Status Update Failed",
        desc: "Failed to update task status. $message",
        type: AlertType.error,
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            width: 120,
          )
        ],
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("💖 $taskTitle 💖",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Posting User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        CachedNetworkImageProvider(postingUserAvatar),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "From: $postingUser 💌",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Task Information Row (Styled like tags)
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  _buildTag("$amount 💰", Colors.greenAccent, Colors.green),
                  _buildTag("Due 📅: $dueDate", Colors.blueAccent, Colors.blue),
                  if (status == 0)
                    _buildTag("Accept By ⏳: $acceptByDate", Colors.orangeAccent,
                        Colors.orange),
                ],
              ),
              SizedBox(height: 20),

              // Task Title
              Text(
                taskTitle,
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
              SizedBox(height: 10),

              // Task Description
              MarkdownBody(
                data: description,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              SizedBox(height: 20),

              // Task Status
              /* Text(
                "Status: ${_getStatusText()} ${_getStatusEmoji()}",
                style: TextStyle(
                  fontSize: 16,
                  color: status == 0
                      ? Colors.orange
                      : status == 1
                      ? Colors.blue
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),*/

              // Task Image
              if (taskImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    taskImage,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 20),

              // Action Buttons
              if (status == 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle accept task
                          updateStatus(context, 1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text("Accept Task 💖",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle reject task
                          updateStatus(context, 2);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text("Reject Task 💔",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ] else if (status == 1) ...[
                //add some padding to this button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle report completion
                      updateStatus(context, 3); // status 3 is completed
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent[100],
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Completed 🚀",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (status) {
      case 0:
        return "To Be Accepted";
      case 1:
        return "In Progress";
      case 2:
        return "Completed";
      default:
        return "Unknown";
    }
  }

  String _getStatusEmoji() {
    switch (status) {
      case 0:
        return "⏳";
      case 1:
        return "🚀";
      case 2:
        return "✅";
      default:
        return "❓";
    }
  }
}
