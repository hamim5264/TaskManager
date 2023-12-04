import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_manager/data/network_caller/network_caller.dart';
import 'package:task_manager/data/network_caller/network_response.dart';
import 'package:task_manager/data/utility/urls.dart';
import 'package:task_manager/ui/widgets/body_background.dart';
import 'package:task_manager/ui/widgets/profile_summary_card.dart';
import 'package:task_manager/ui/widgets/snack_message.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({super.key});

  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final TextEditingController _titleTEController = TextEditingController();
  final TextEditingController _descriptionTEController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _createTaskInProgress = false;
  bool newTaskAdded = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        Navigator.pop(context, newTaskAdded);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const ProfileSummaryCard(),
              Expanded(
                child: BodyBackground(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 32,
                            ),
                            Text(
                              "Add New Task",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              controller: _titleTEController,
                              decoration:
                                  const InputDecoration(hintText: "Title"),
                              validator: (String? value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return "Title Required!";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              controller: _descriptionTEController,
                              maxLines: 8,
                              decoration: const InputDecoration(
                                  hintText: "Description"),
                              validator: (String? value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return "Description Required!";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Visibility(
                                visible: _createTaskInProgress == false,
                                replacement: const Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.green,
                                    color: Colors.white,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: createTask,
                                  child: const Icon(
                                    CupertinoIcons.arrow_up_circle_fill,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createTask() async {
    if (_formKey.currentState!.validate()) {
      _createTaskInProgress = true;
      if (mounted) {
        setState(() {});
      }
      final NetworkResponse response =
          await NetworkCaller().postRequest(Urls.createNewTask, body: {
        "title": _titleTEController.text.trim(),
        "description": _descriptionTEController.text.trim(),
        "status": "New",
      });
      _createTaskInProgress = false;
      if (mounted) {
        setState(() {});
      }
      if (response.isSuccess) {
        newTaskAdded = true;
        _titleTEController.clear();
        _descriptionTEController.clear();
        if (mounted) {
          showSnackMessage(context, "New task added successfully!");
          Navigator.pop(context, newTaskAdded);
        }
      } else {
        if (mounted) {
          showSnackMessage(context, "Create new task failed! Try again.", true);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleTEController.dispose();
    _descriptionTEController.dispose();
    super.dispose();
  }
}
