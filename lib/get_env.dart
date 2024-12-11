import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home/login.dart';
import 'user.dart';

//A helper class to get environment variables
class GetEnv {
  static String getApiBaseUrl() {
    return dotenv.env["API_BASEURL"] ?? "https://togethercoins.jianqinggao.com";
  }

  static String getPrefillUsername() {
    return dotenv.env["PREFILL_USERNAME"] ?? "";
  }

  static String getPrefillPassword() {
    return dotenv.env["PREFILL_PASSWORD"] ?? "";
  }

  static String getFileBaseUrl() {
    return dotenv.env["FILE_BASEURL"] ??
        "https://togethercoins.jianqinggao.com";
  }

  static iePath(String path) {
    if (path.startsWith("http")) {
      return path;
    }
    return getFileBaseUrl() + path;
  }

  static Future<User> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson == null) {
      return Future.error("user is null!");
    }
    return User.fromJson(jsonDecode(userJson));
  }

  static Future<void> setUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  static Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  //set bind user
  static Future<void> setBindUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bind_user', jsonEncode(user.toJson()));
  }

  static Future<User> getBindUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('bind_user');
    if (userJson == null) {
      return Future.error("bind user is null!");
    }
    return User.fromJson(jsonDecode(userJson));
  }

  static Future<http.StreamedResponse> uploadFile(List<File> files, String jwtToken) async {
    //upload file to server
    //get the file path and add to the selected list
    //upload to base+/upload
    var request = http.MultipartRequest(
        'POST', Uri.parse('${GetEnv.getApiBaseUrl()}/files/upload'),
    );
    request.headers['Authorization']="Bearer $jwtToken";
    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }
    return await request.send();
  }

  static void alert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void goLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
