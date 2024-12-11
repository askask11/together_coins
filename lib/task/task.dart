import 'package:flutter/material.dart';

class Task {
  int task_id;
  String title;
  String description;
  int status;
  String created_on;
  int num_days;
  int num_days_accept;
  int by_user;
  int numCoins;

  Task(
      {required this.task_id,
      required this.title,
      required this.description,
      required this.status,
      required this.created_on,
      required this.num_days,
      required this.num_days_accept,
      required this.by_user,
      required this.numCoins});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        task_id: json['task_id'],
        title: json['title'],
        description: json['description'],
        status: json['status'],
        created_on: json['created_on'],
        num_days: json['num_days'],
        num_days_accept: json['num_days_accept'],
        by_user: json['by_user'],
        numCoins: json['num_coins']);
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': task_id,
      'title': title,
      'description': description,
      'status': status,
      'created_on': created_on,
      'num_days': num_days,
      'num_days_accept': num_days_accept,
      'by_user': by_user,
      'num_coins': numCoins
    };
  }

  // get due date = created_on + num_days
  DateTime getDueDate() {
    return DateTime.parse(created_on).add(Duration(days: num_days));
  }

  //get due date formatted in yyyy-mm-dd
  String getDueDateFormatted() {
    return getDueDate().toString().substring(0, 10);
  }

  ///get status string
  ///
  /// 0: To be accepted, 1: Accepted, 2: Rejected, 3: Completed
  String getStatusString() {
    switch (status) {
      case 0:
        return "To be accepted";
      case 1:
        return "Accepted";
      case 2:
        return "Rejected";
      case 3:
        return "Completed";
      default:
        return "Unknown";
    }

    ///
  }

  ///get status color
  ///
  /// 0: To be accepted, 1: Accepted, 2: Rejected, 3: Completed
  Color getStatusColor() {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
