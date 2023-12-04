import 'package:shared_preferences/shared_preferences.dart';

///Write all user data fon only verify (email, otp, reset password)
Future<void> writeUserData(userData) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("token", userData["token"]);
  await prefs.setString("email", userData["data"]["email"]);
  await prefs.setString("firstName", userData["data"]["firstName"]);
  await prefs.setString("lastName", userData["data"]["lastName"]);
  await prefs.setString("mobile", userData["data"]["mobile"]);
  await prefs.setString("photo", userData["data"]["photo"]);
}

Future<void> writeEmailVerification(email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("EmailVerification", email);
}

Future<void> writeOTPVerification(otp) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("OTPVerification", otp);
}

///Read all user data fon only verify (email, otp, reset password)
Future<String?> readUserData(key) async {
  final prefs = await SharedPreferences.getInstance();
  String? myData = prefs.getString(key);
  return myData;
}
