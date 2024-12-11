import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../get_env.dart';
import "../user.dart";
import 'edit_task.dart';
import 'task.dart';
import 'task_detail.dart';

/**
 * {
    "task_id": 1,
    "title": "Do Laundry",
    "description": "clean laundry",
    "status": 0, ((0: To be accepted, 1: Accepted, 2: Rejected, 3: Completed)
    "created_on": "2024-11-30T05:51:57.000Z",
    "num_days": 7,
    "num_days_accept": 4,
    "by_user": 1
    }
 */

/*
{
        "in_progress_tasks": [],
        "to_be_accepted_tasks": [
            {
                "task_id": 1,
                "title": "Do Laundry",
                "description": "clean laundry",
                "status": 0,
                "created_on": "2024-11-30T05:51:57.000Z",
                "num_days": 7,
                "num_days_accept": 4,
                "by_user": 1
            },
            {
                "task_id": 2,
                "title": "Buy drinks",
                "description": "We are running out of drinks, buy some",
                "status": 0,
                "created_on": "2024-11-30T06:10:25.000Z",
                "num_days": 4,
                "num_days_accept": 1,
                "by_user": 1
            }
        ],
        "completed_tasks": []
    }
 */
class TaskPageState {
  List<Task> inProgressTasks = [];
  List<Task> toBeAcceptedTasks = [];
  List<Task> completedTasks = [];
  String errorMessage;
  bool isLoading;
  int whoseTask =
      1; // -1 tasks which I post to him, anything else is their tasks posted to me
  User user;
  User bindUser;

  //by default give them empty lists
  TaskPageState(
      {required this.inProgressTasks,
      required this.toBeAcceptedTasks,
      required this.completedTasks,
      required this.errorMessage,
      this.isLoading = true,
      required this.whoseTask,
      required this.user,
      required this.bindUser});

  TaskPageState.empty(int whoseTask, User user, User bindUser)
      : this(
            inProgressTasks: [],
            toBeAcceptedTasks: [],
            completedTasks: [],
            errorMessage: "",
            whoseTask: whoseTask,
            user: user,
            bindUser: bindUser);

  TaskPageState.copy(TaskPageState state)
      : this(
            inProgressTasks: state.inProgressTasks,
            toBeAcceptedTasks: state.toBeAcceptedTasks,
            completedTasks: state.completedTasks,
            errorMessage: state.errorMessage,
            isLoading: state.isLoading,
            whoseTask: state.whoseTask,
            user: state.user,
            bindUser: state.bindUser);

  factory TaskPageState.fromJson(
      Map<String, dynamic> json, int whoseTask, User user, User bindUser) {
    List<Task> inProgressTasks = [];
    List<Task> toBeAcceptedTasks = [];
    List<Task> completedTasks = [];

    for (var task in json['in_progress_tasks']) {
      inProgressTasks.add(Task.fromJson(task));
    }

    for (var task in json['to_be_accepted_tasks']) {
      toBeAcceptedTasks.add(Task.fromJson(task));
    }

    for (var task in json['completed_tasks']) {
      completedTasks.add(Task.fromJson(task));
    }

    return TaskPageState(
        inProgressTasks: inProgressTasks,
        toBeAcceptedTasks: toBeAcceptedTasks,
        completedTasks: completedTasks,
        errorMessage: "",
        isLoading: false,
        whoseTask: whoseTask,
        user: user,
        bindUser: bindUser);
  }
}

class TaskPageCubit extends Cubit<TaskPageState> {
  TaskPageCubit(int whoseTask, User user, User bindUser)
      : super(TaskPageState.empty(whoseTask, user, bindUser));

  void loadTasks() {
    state.isLoading = true;
    User user = state.user;
    int whoseTask = state.whoseTask;
    User bindUser = state.bindUser;
    http.get(
      Uri.parse(
        "${GetEnv.getApiBaseUrl()}/task/list?by=${whoseTask == -1 ? 'me' : 'them'}",
      ),
      headers: {
        'Authorization': 'Bearer ${user.jwtToken}',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        emit(TaskPageState.fromJson(data["data"], whoseTask, user, bindUser));
      } else if (response.statusCode == 403) {
        state.errorMessage = "You have timed out. Please login again";
        state.isLoading = false;
        emit(TaskPageState.copy(state));
      } else {
        state.isLoading = false;
        state.errorMessage = "Failed to load tasks";
        emit(TaskPageState.copy(state));
      }
    }).catchError((error) {
      state.isLoading = false;
      state.errorMessage = "Failed to load tasks";
      emit(TaskPageState.copy(state));
    });
  }
}

class MyTasksBoardPage extends StatelessWidget {
  final User user;
  final User bindUser;

  MyTasksBoardPage(
      {Key? key,
      this.whoseTask = 1,
      required this.user,
      required this.bindUser})
      : super(key: key);

  final int
      whoseTask; // -1 tasks which I post to him, anything else is their tasks posted to me

  Future<void> refresh(BuildContext context) async {
    BlocProvider.of<TaskPageCubit>(context).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('Tasks For ${whoseTask == -1 ? "Them" : "Me"} 📜',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.archive, color: Colors.white),
            tooltip: 'View Completed Tasks (Archive)',
            onPressed: () {
              // Navigate to the completed tasks page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompletedTasksPage()),
              );
            },
          ),
          whoseTask == -1
              ? SizedBox()
              : IconButton(
                  icon: CircleAvatar(
                    radius: 17,
                    backgroundImage: CachedNetworkImageProvider(
                        GetEnv.iePath(user.avatarPath)),
                  ),
                  tooltip: 'View Your Posted Tasks',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyTasksBoardPage(
                                whoseTask: -1,
                                user: user,
                                bindUser: bindUser,
                              )),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: whoseTask == -1
          ? FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              onPressed: () {
                // Handle post new task
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditCreateTaskPage.add(
                            user,
                            bindUser,
                          )),
                );
              },
              child: Icon(Icons.add),
              tooltip: 'Post New Task',
            )
          : null,
      body: BlocProvider<TaskPageCubit>(
        create: (context) =>
            TaskPageCubit(whoseTask, user, bindUser)..loadTasks(),
        child: Builder(
          builder: (context) => RefreshIndicator(
            onRefresh: () => refresh(context),
            child: BlocBuilder<TaskPageCubit, TaskPageState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  physics: AlwaysScrollableScrollPhysics(),
                  // Ensures pull-to-refresh works
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: CachedNetworkImageProvider(
                            GetEnv.iePath(whoseTask == -1
                                ? user.avatarPath
                                : bindUser.avatarPath),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SectionHeader(title: "In Progress ⏳"),
                    SizedBox(height: 5),
                    state.isLoading
                        ? LoadingSection.loading()
                        : TaskGrid(
                            tasks: state.inProgressTasks,
                            taskType: "In Progress",
                            taskStatusColor: Colors.blue,
                          ),
                    SectionHeader(title: "To Be Accepted 📄"),
                    SizedBox(height: 5),
                    state.isLoading
                        ? LoadingSection.loading()
                        : TaskGrid(
                            tasks: state.toBeAcceptedTasks,
                            taskType: "To Be Accepted",
                            taskStatusColor: Colors.orange,
                          ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

//loading section: a row with a circular progress indicator and a text message, on the center shows loading
class LoadingSection extends StatelessWidget {
  final String message;

  LoadingSection({required this.message});

  //default message
  LoadingSection.loading() : message = "Loading...";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 10),
          Text(message),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent,
        ),
      ),
    );
  }
}

class TaskGrid extends StatelessWidget {
  //final int taskCount;
  final List<Task> tasks;
  final String taskType;
  final Color taskStatusColor;

  TaskGrid({
    //required this.taskCount,
    required this.tasks,
    required this.taskType,
    required this.taskStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    TaskPageCubit cubit = BlocProvider.of<TaskPageCubit>(context);
    final String errorMessage = cubit.state.errorMessage;
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          errorMessage.isEmpty ? "No tasks found." : errorMessage,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 4 / 3,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          taskTitle: tasks[index].title,
          status: taskType,
          statusColor: taskStatusColor,
          dueDate: "Due: ${tasks[index].getDueDateFormatted()}",
          amount: "${tasks[index].numCoins} 💰",
          task: tasks[index],
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final String taskTitle;
  final String status;
  final Color statusColor;
  final String dueDate;
  final String amount;

  //final int whoseTask = -1; // TODO change this
  final Task task;

  TaskCard({
    required this.taskTitle,
    required this.status,
    required this.statusColor,
    required this.dueDate,
    required this.amount,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    TaskPageCubit cubit = BlocProvider.of<TaskPageCubit>(context);
    int whoseTask = cubit.state.whoseTask;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: whoseTask == -1
                  ? ((context) => EditCreateTaskPage.edit(
                      task, cubit.state.user, cubit.state.bindUser))
                  : ((context) => TaskDetailPage.from(
                      cubit.state.user, cubit.state.bindUser, task))),
        );
      },
      borderRadius: BorderRadius.circular(16.0),
      splashColor: Colors.pink.withAlpha(30),
      child: Card(
        color: Colors.pink[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                taskTitle,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

class CompletedTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Completed Tasks (Archive) 📂'),
      ),
      body: Center(
        child: Text(
          "List of completed tasks will be shown here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
