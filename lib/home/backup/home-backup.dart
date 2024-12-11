import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(HomeApp());
}

class HomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'TogetherCoins',
      theme: customTheme3,
      home: HomePage(),
    );
  }
}

final ThemeData customTheme3 = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
  useMaterial3: true, // Enables Material Design 3 styles
);

class TaskCard extends StatelessWidget {
  final String taskTitle;
  final String description;
  final String dueDate;
  final bool isAccepted;
  final int coins;

  TaskCard({
    required this.taskTitle,
    required this.description,
    required this.dueDate,
    required this.isAccepted,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Stack(
        children: [
          Container(
            width: 200,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(taskTitle, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 10),
                Text(description,
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 10),
                Text("Due: $dueDate",
                    style: Theme.of(context).textTheme.bodySmall),
                SizedBox(height: 10),
                Text(isAccepted ? "Status: Accepted" : "Status: Pending",
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                border: Border.all(color: Colors.amber.shade400),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text("💰 $coins",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniStoreCard extends StatelessWidget {
  final String rewardTitle;
  final String rewardDescription;
  final int coins;

  MiniStoreCard({
    required this.rewardTitle,
    required this.rewardDescription,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Stack(
        children: [
          Container(
            width: 200,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rewardTitle,
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 10),
                Text(rewardDescription,
                    style: Theme.of(context).textTheme.bodyMedium),
                Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Redeem 💸"),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text("💰 $coins",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<String> loveQuotes = [
    "Love is not about how much you say 'I love you', but how much you prove that it's true.",
    "You are my today and all of my tomorrows.",
    "In all the world, there is no heart for me like yours.",
    "You are the best thing that’s ever been mine.",
    "Together is a wonderful place to be.",
    "I love you, not only for what you are but for what I am when I am with you."
  ];

  String getRandomLoveQuote() {
    final random = Random();
    return loveQuotes[random.nextInt(loveQuotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TogetherCoins 💖'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            AssetImage('assets/images/avatar1.png'),
                      ),
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            AssetImage('assets/images/avatar2.png'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Welcome back, Alex! 💕",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10),
                  Text(
                    getRandomLoveQuote(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // My Tasks Board - Uber-style Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tasks Available 📝",
                          style: Theme.of(context).textTheme.titleLarge),
                      TextButton(
                        onPressed: () {},
                        child: Text("View All Tasks"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Example task count
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: TaskCard(
                            taskTitle: "Task #${index + 1}",
                            description: "Complete a fun activity together!",
                            dueDate: "2024-12-01",
                            isAccepted: index % 2 == 0,
                            // Example status
                            coins: 20 + (index * 5),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Mini-Store Highlight - Uber-style Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mini-Store Rewards 🛍️",
                          style: Theme.of(context).textTheme.titleLarge),
                      TextButton(
                        onPressed: () {},
                        child: Text("View Full Store"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Example reward count
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: MiniStoreCard(
                            rewardTitle: "Reward #${index + 1}",
                            rewardDescription: "Get a free ice cream treat! 🍦",
                            coins: 50 + (index * 10),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Shared Experiences
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Shared Experiences 🎶",
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.music_note),
                        label: Text("Music Session 🎵"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Memory Board
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.photo_album,
                      color: Theme.of(context).colorScheme.tertiary),
                  title: Text("Memory Board 📚",
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text("🖼️ Scroll through your shared moments!",
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
