import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager/data/models/user_model.dart';
import 'package:task_manager/data/network_caller/network_caller.dart';
import 'package:task_manager/data/network_caller/network_response.dart';
import 'package:task_manager/data/utility/urls.dart';
import 'package:task_manager/ui/controllers/auth_controller.dart';
import 'package:task_manager/ui/widgets/body_background.dart';
import 'package:task_manager/ui/widgets/profile_summary_card.dart';
import 'package:task_manager/ui/widgets/snack_message.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _firstNameTEController = TextEditingController();
  final TextEditingController _lastNameTEController = TextEditingController();
  final TextEditingController _mobileTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _updateProfileInProgress = false;
  XFile? photo;

  @override
  void initState() {
    super.initState();
    _emailTEController.text = AuthController.user?.email ?? "";
    _firstNameTEController.text = AuthController.user?.firstName ?? "";
    _lastNameTEController.text = AuthController.user?.lastName ?? "";
    _mobileTEController.text = AuthController.user?.mobile ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ProfileSummaryCard(
              enableOnTap: false,
            ),
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
                            "Update Profile",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: photoPickerField(),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: InkWell(
                                    onTap: () async {
                                      final XFile? image =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 50,
                                      );
                                      if (image != null) {
                                        photo = image;
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Visibility(
                                        visible: photo == null,
                                        replacement: Text(photo?.name ?? ""),
                                        child: const Text("Select a photo"),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: _emailTEController,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(hintText: "Email"),
                            validator: (String? value) {
                              if (value?.trim().isEmpty ?? true) {
                                return "Email required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: _firstNameTEController,
                            decoration:
                                const InputDecoration(hintText: "First name"),
                            validator: (String? value) {
                              if (value?.trim().isEmpty ?? true) {
                                return "First name required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: _lastNameTEController,
                            decoration:
                                const InputDecoration(hintText: "Last name"),
                            validator: (String? value) {
                              if (value?.trim().isEmpty ?? true) {
                                return "Last name required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: _mobileTEController,
                            keyboardType: TextInputType.phone,
                            decoration:
                                const InputDecoration(hintText: "Mobile"),
                            validator: (String? value) {
                              if (value?.trim().isEmpty ?? true) {
                                return "Mobile required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: _passwordTEController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                hintText: "Password (Optional)"),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Visibility(
                              visible: _updateProfileInProgress == false,
                              replacement: const Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.green,
                                  color: Colors.white,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: profileUpdate,
                                child: const Icon(
                                  CupertinoIcons.arrow_right_circle_fill,
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
    );
  }

  Future<void> profileUpdate() async {
    if (_formKey.currentState!.validate()) {
      _updateProfileInProgress = true;
      if (mounted) {
        setState(() {});
      }
      String? photoInBase64;
      Map<String, dynamic> inputData = {
        "email": _emailTEController.text.trim(),
        "firstName": _firstNameTEController.text.trim(),
        "lastName": _lastNameTEController.text.trim(),
        "mobile": _mobileTEController.text.trim(),
      };

      if (_passwordTEController.text.isNotEmpty) {
        inputData["password"] = _passwordTEController.text;
      }

      if (photo != null) {
        List<int> imageBytes = await photo!.readAsBytes();
        photoInBase64 = base64Encode(imageBytes);
        inputData["photo"] = photoInBase64;
      }

      final NetworkResponse response = await NetworkCaller()
          .postRequest(Urls.updateProfile, body: inputData);
      _updateProfileInProgress = false;
      if (mounted) {
        setState(() {});
      }

      if (response.isSuccess) {
        AuthController.updateUserInformation(
          UserModel(
              email: _emailTEController.text.trim(),
              firstName: _firstNameTEController.text.trim(),
              lastName: _lastNameTEController.text.trim(),
              mobile: _mobileTEController.text.trim(),
              photo: photoInBase64 ?? AuthController.user?.photo),
        );

        if (mounted) {
          Navigator.pop(context);
          showSnackMessage(context, "Update profile success!");
        }
      } else {
        if (mounted) {
          showSnackMessage(context, "Update profile failed! Try again.", true);
        }
      }
    }
  }

  Container photoPickerField() {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        "Photo",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    _firstNameTEController.dispose();
    _lastNameTEController.dispose();
    _mobileTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}
