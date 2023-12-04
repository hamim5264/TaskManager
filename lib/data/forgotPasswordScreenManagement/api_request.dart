import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_manager/data/forgotPasswordScreenManagement/user_utility.dart';

var baseURL = "https://task.teamrabbil.com/api/v1";
var requestHeader = {"Content-Type": "application/json"};

///Recover verify email request
Future<bool> verifyEmailRequest(email) async {
  var url = Uri.parse("$baseURL/RecoverVerifyEmail/$email");
  var response = await http.get(url, headers: requestHeader);
  var resultCode = response.statusCode;
  var resultBody = json.decode(response.body);
  if (resultCode == 200 && resultBody['status'] == "success") {
    await writeEmailVerification(email); //store user email
    return true;
  } else {
    return false;
  }
}

///Verify OTP request
Future<bool> verifyOTPRequest(email, otp) async {
  var url = Uri.parse("$baseURL/RecoverVerifyOTP/$email/$otp");
  var response = await http.get(url, headers: requestHeader);
  var resultCode = response.statusCode;
  var resultBody = json.decode(response.body);
  if (resultCode == 200 && resultBody['status'] == "success") {
    await writeOTPVerification(otp); //store user otp
    return true;
  } else {
    return false;
  }
}

///Set new password request
Future<bool> setPasswordRequest(formValues) async {
  var url = Uri.parse("$baseURL/RecoverResetPass");
  var postBody = json.encode(formValues);
  var response = await http.post(url, headers: requestHeader, body: postBody);
  var resultCode = response.statusCode;
  var resultBody = json.decode(response.body);
  if (resultCode == 200 && resultBody['status'] == "success") {
    return true;
  } else {
    return false;
  }
}
