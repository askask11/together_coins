import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../coming_soon.dart';
import '../get_env.dart';
import '../user.dart';
import "home.dart";

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController =
      TextEditingController(text: dotenv.env["PREFILL_USERNAME"]);
  final TextEditingController _passwordController =
      TextEditingController(text: dotenv.env["PREFILL_PASSWORD"]);

  LoginPage({super.key});

  void alert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showsLoggingIn(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logging in'),
          content: SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  void dismissLoggingIn(BuildContext context) {
    Navigator.of(context).pop();
  }

  void login(BuildContext context) {
    // Handle login action
    //print("base url is ${dotenv.env["API_BASEURL"]??"bruh no value"}");
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String signInApi = "${GetEnv.getApiBaseUrl()}/user/login";
    if (email.isEmpty || password.isEmpty) {
      // Show error message
      alert(context, 'Email and password are required');
      return;
    }
    showsLoggingIn(context);
    //send a POST request to the server
    final body = jsonEncode({
      "username": email, //vip@jianqinggao.com
      "password": md5.convert(utf8.encode(password)).toString(),
    });

    http
        .post(
      Uri.parse(signInApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    )
        .then((response) {
      if (response.statusCode == 200) {
        // Login successful
        // Navigate to the home page
        //parse response to json

        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final User user = User.fromJson(jsonResponse["data"]["user"]);
        user.jwtToken = jsonResponse["data"]["token"];
        final User bindUser;
        //print("oooook!");
        if (jsonResponse["data"]["bind_user"] == null) {
          print("bind user is null, base url is ${GetEnv.getApiBaseUrl()}");
          bindUser = User(
              userId: 0,
              name: "-",
              email: "",
              city: user.city,
              timeZone: user.timeZone,
              avatarPath: "${GetEnv.getApiBaseUrl()}/images/faq.png",
              coinBalance: 0,
              barkUrl: "",
              bindedUser: -1,
              token: "",
              status: 0,
              statusIcon: "",
              statusName: "");
        } else {
          bindUser = User.fromJson(jsonResponse["data"]["bind_user"]);
        }
        GetEnv.setUser(user);
        GetEnv.setBindUser(bindUser);
        dismissLoggingIn(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(
                  user: user,
                  bindUser: bindUser,
                )));
      } else {
        // Login failed
        // Show error message
        print(response.body);
        alert(context, 'Invalid email or password');
      }
    }).catchError((error, stackTrace) {
      alert(context, 'An error occurred, please try again later');
      //print stack trace
      print(error);
      print(stackTrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
                /*gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),*/
                ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Container(
                    padding: EdgeInsets.all(4.0),
                    // Adjust the padding to control the border width
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.pinkAccent,
                        width:
                            2.0, // Adjust the width to control the border thickness
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.music_note,
                        color: Colors.pinkAccent,
                        size: 50,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Email Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "📧 Email",
                      labelStyle: TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.pinkAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      filled: true,
                      fillColor: Colors.pink[50],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "🔑 Password",
                      labelStyle: TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            BorderSide(color: Colors.pinkAccent, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.pinkAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      filled: true,
                      fillColor: Colors.pink[50],
                    ),
                  ),
                  SizedBox(height: 30),
                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      // Handle login action
                      login(context);
                    },
                    child: Text('Login',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Sign Up Button
                  TextButton(
                    onPressed: () {
                      // Handle sign up action
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ComingSoonPage(
                                feature: "Sign up",
                              )));
                    },
                    child: Text('Don\'t have an account? Sign Up',
                        style:
                            TextStyle(color: Colors.pinkAccent, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
