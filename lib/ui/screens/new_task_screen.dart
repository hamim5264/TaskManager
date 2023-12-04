import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task_count.dart';
import 'package:task_manager/data/models/task_count_summary_list_model.dart';
import 'package:task_manager/data/models/task_list_model.dart';
import 'package:task_manager/data/network_caller/network_caller.dart';
import 'package:task_manager/data/network_caller/network_response.dart';
import 'package:task_manager/data/utility/urls.dart';
import 'package:task_manager/ui/screens/add_new_task_screen.dart';
import 'package:task_manager/ui/widgets/profile_summary_card.dart';
import 'package:task_manager/ui/widgets/summary_card.dart';
import 'package:task_manager/ui/widgets/task_item_card.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({
    super.key,
  });

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  bool getNewTaskInProgress = false;
  bool getTaskCountSummaryInProgress = false;
  bool taskCountChange = false;

  TaskListModel taskListModel = TaskListModel();
  TaskCountSummaryListModel taskCountSummaryListModel =
      TaskCountSummaryListModel();

  Future<void> getTaskCountSummaryList() async {
    getTaskCountSummaryInProgress = true;
    if (mounted) {
      setState(() {});
    }
    final NetworkResponse response =
        await NetworkCaller().getRequest(Urls.getTaskStatusCount);
    if (response.isSuccess) {
      taskCountSummaryListModel =
          TaskCountSummaryListModel.fromJson(response.jsonResponse);
    }
    getTaskCountSummaryInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getNewTaskList() async {
    getNewTaskInProgress = true;
    taskCountChange = true;
    if (mounted) {
      setState(() {});
    }
    final NetworkResponse response =
        await NetworkCaller().getRequest(Urls.getNewTasks);
    if (response.isSuccess) {
      taskListModel = TaskListModel.fromJson(response.jsonResponse);
      getTaskCountSummaryList();
    }
    getNewTaskInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getTaskCountSummaryList();
    getNewTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        Navigator.pop(context, taskCountChange);
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () async {
            final response = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewTaskScreen(),
              ),
            );
            if (response != null && response == true) {
              getNewTaskList();
              getTaskCountSummaryList();
            }
          },
          child: const Icon(
            CupertinoIcons.add_circled_solid,
            color: Colors.white,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const ProfileSummaryCard(),
              Visibility(
                visible: getTaskCountSummaryInProgress == false,
                replacement: const LinearProgressIndicator(
                  backgroundColor: Colors.green,
                  color: Colors.white,
                ),
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          taskCountSummaryListModel.taskCountList?.length ?? 0,
                      itemBuilder: (context, index) {
                        TaskCount taskCount =
                            taskCountSummaryListModel.taskCountList![index];
                        return FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            child: SummaryCard(
                              count: taskCount.sum.toString(),
                              title: taskCount.sId ?? "",
                            ),
                          ),
                        );
                      }),
                ),
              ),
              Expanded(
                child: Visibility(
                  visible: getNewTaskInProgress == false &&
                      (taskCountSummaryListModel.taskCountList?.isNotEmpty ??
                          false),
                  replacement: const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.green,
                      color: Colors.white,
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: getNewTaskList,
                    child: ListView.builder(
                        itemCount: taskListModel.taskList?.length ?? 0,
                        itemBuilder: (context, index) {
                          return TaskItemCard(
                            task: taskListModel.taskList![index],
                            onStatusChange: () {
                              getNewTaskList();
                            },
                            showProgress: (inProgress) {
                              getNewTaskInProgress = inProgress;
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
