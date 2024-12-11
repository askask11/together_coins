import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../get_env.dart';
import '../music/music_session.dart';
import "../task/mini_store.dart";
import "../task/my_tasks_board.dart";
import '../user.dart';
import 'home_state.dart';

void main0() {
  //runApp(HomeApp(user: User(userId: 1, name: "Jialin", email: "jialin@jianqinggao.com", city: "Guangzhou", timeZone: 8, avatarPath: "", coinBalance: 1, barkUrl: "", bindedUser: 2, token: null, status: 1, statusIcon: '😃',statusName: '开心'),));
}

/*class HomeApp extends StatelessWidget
{
  final User user;
  const HomeApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'TogetherCoins',
      theme: customTheme3,
      home: HomePage(user: user,bindUser: null,),
    );
  }

}*/

final ThemeData customTheme3 = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
  useMaterial3: true, // Enables Material Design 3 styles
);

class HomePage extends StatelessWidget {
  final User user;
  final User bindUser;

  const HomePage({super.key, required this.user, required this.bindUser});

  @override
  Widget build(BuildContext context) {
    print("HomePage build");
    //print user object
    //print(user);
    //print(bindUser);
    return PopScope(
      canPop: false,
      child: BlocProvider<HomeCubic>(
        create: (context) => HomeCubic(user, bindUser),
        child: BlocBuilder<HomeCubic, HomeState>(
            builder: (context, state) => RefreshIndicator(
                onRefresh: () {
                  print("shsh");
                  return BlocProvider.of<HomeCubic>(context).loadCoins();
                },
                child: HomePageScaffold())),
      ),
    );
  }
}

class HomePageScaffold extends StatelessWidget {
  /*final User user;
  final User bindUser;*/

  const HomePageScaffold({super.key});

  void sendMessage(BuildContext context) {
    User user = BlocProvider.of<HomeCubic>(context).state.user;
    User bindUser = BlocProvider.of<HomeCubic>(context).state.bindUser;
    //send message action
    if (bindUser.userId == 0) {
      Alert(
              context: context,
              title: "Error",
              desc: "Please bind a user first",
              type: AlertType.warning)
          .show();
      return;
    }

    if (bindUser.barkUrl.isEmpty) {
      Alert(
              context: context,
              title: "Error",
              desc: "The other user has not set up a notifier yet.",
              type: AlertType.warning)
          .show();
      return;
    }

    final cubic = BlocProvider.of<HomeCubic>(context);
    final String message = cubic.state.textEditingController.text;
    //if the message is empty
    if (message.isEmpty) {
      Alert(
              context: context,
              title: "Error",
              desc: "Message cannot be empty",
              type: AlertType.warning)
          .show();
      return;
    }

    //do a http get request
    http
        .get(Uri.parse(
            "${bindUser.barkUrl}/${user.name}send you a message/$message"))
        .then((response) {
      if (response.statusCode == 200) {
        //show success message
        Alert(
                context: context,
                title: "Success",
                desc: "Message sent successfully",
                type: AlertType.success)
            .show();
        cubic.updateText("");
      } else {
        //show error message
        Alert(
                context: context,
                title: "Error",
                desc: "An error occurred, please try again later",
                type: AlertType.error)
            .show();
      }
    }).catchError((error) {
      //show error message
      Alert(
              context: context,
              title: "Error",
              desc: "An error occurred, please try again later",
              type: AlertType.error)
          .show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeCubic = BlocProvider.of<HomeCubic>(context);
    final User user = homeCubic.state.user;
    final User bindUser = homeCubic.state.bindUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        leadingWidth: 260,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                //get images from the internet
                backgroundImage:
                    CachedNetworkImageProvider(GetEnv.iePath(user.avatarPath)),
              ),
              SizedBox(width: 5),
              Icon(Icons.favorite, color: Colors.white),
              SizedBox(width: 5),
              CircleAvatar(
                  radius: 15,
                  backgroundImage: CachedNetworkImageProvider(
                      GetEnv.iePath(bindUser.avatarPath))),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "💰 Coins: ${user.coinBalance}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(
                        GetEnv.iePath(user.avatarPath)),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Welcome back, ${user.name}!",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Let's make today amazing together! 🌟",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Send Message Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: homeCubic.state.textEditingController,
                      decoration: InputDecoration(
                        hintText: "Send a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Send message action
                      sendMessage(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15.0),
                    ),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),

            // My Tasks Board
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
              child: ReusableCard(
                icon: Icons.checklist,
                title: "My Tasks Board 📜",
                subtitle: "View and manage your tasks",
                onTap: () {
                  // Navigate to My Tasks Board
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MyTasksBoardPage(
                            user: user,
                            bindUser: bindUser,
                          )));
                },
              ),
            ),

            // Mini-Store Highlight
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
              child: ReusableCard(
                icon: Icons.shopping_bag,
                title: "Mini-Store 🛋️",
                subtitle: "Redeem coins from your loved ones",
                onTap: () {
                  // Navigate to Mini-Store
                  Alert(
                    context: context,
                    title: "Mini-Store Prototype",
                    desc:
                        "You are viewing a prototype of the Mini-Store. It's not connected to the database. Click OK to continue, or Cancel to go back.",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "OK",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MiniStorePage()));
                        },
                        width: 120,
                      ),
                      DialogButton(
                        onPressed: () => Navigator.pop(context),
                        width: 120,
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ],
                  ).show();
                },
              ),
            ),

            // Shared Experiences - Music Session
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
              child: ReusableCard(
                icon: Icons.music_note,
                title: "Music Session 🎵",
                subtitle: "Enjoy music together in real-time!",
                onTap: () {
                  // Navigate to Music Session
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MusicSessionBoard(
                            user: user,
                            bindUser: bindUser,
                          )));
                },
              ),
            ),

            //make a small logout button, not a full card
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle logout action
                  Navigator.of(context).pop();
                  //Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.pinkAccent,
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Logout 🚪',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ReusableCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  ReusableCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.pink[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          splashColor: Colors.pinkAccent.withOpacity(0.2),
          highlightColor: Colors.pinkAccent.withOpacity(0.1),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.pinkAccent),
                    SizedBox(width: 10),
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
