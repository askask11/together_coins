import 'package:flutter/material.dart';

//// A page telling the user that the feature is coming soon.
class ComingSoonPage extends StatelessWidget {
  final String feature;

  const ComingSoonPage({super.key, this.feature = 'Something awesome'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coming Soon',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 100,
              color: Colors.pinkAccent,
            ),
            SizedBox(height: 20),
            Text(
              '$feature is on the way!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Stay tuned, we are working hard to bring this feature to you.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
